// lib/main.dart
import'package:flutter/material.dart';import'package:flutter_bloc/flutter_bloc.dart';import'package:boom_boom/bloc/bubble_game_bloc.dart';import'package:boom_boom/services/audio_service.dart';import'dart:async';import'home_screen.dart';import'package:font_awesome_flutter/font_awesome_flutter.dart';import'package:collection/collection.dart';//ProvidesfirstWhereOrNull
//---GLOBALSERVICESANDHELPERS---
final AudioService audioService=AudioService();
//Globalfunctiontoreturntothehomescreen
void _goHome(BuildContext context){
  audioService.stopBackgroundMusic();
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder:(context)=>const HomeScreen()),
  );
}
//------------------------------------
//---COREAPPLICATIONLAUNCHER(Singlemainfunction)---
void main(){
//Ensurethemainfunctionistheveryfirstexecutablepieceofcode
  audioService.init();
  runApp(const MainAppWrapper());
}
class MainAppWrapper extends StatelessWidget{
  const MainAppWrapper({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title:'Bubble Pop Game',
      theme:ThemeData(
        primarySwatch:Colors.blue,
      ),
      home:const HomeScreen(),
    );
  }
}
//---BUBBLEGAMESCREEN(TheactualgameUI)---
class BubbleGameScreen extends StatefulWidget{
  const BubbleGameScreen({super.key});
  @override
  State<BubbleGameScreen> createState()=>_BubbleGameScreenState();
}
class _BubbleGameScreenState extends State<BubbleGameScreen>with TickerProviderStateMixin{
  late Timer _spawnTimer;
  late Timer _collisionTimer;
//Trackanimationsforpoppedfacts
  final Map<UniqueKey,AnimationController>_factControllers={};
//Helperfunctiontorestartthegamestate
  void _startNewGame(){
    audioService.stopBackgroundMusic();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:(context)=>BlocProvider(
          create:(context)=>BubbleGameBloc(),
          child:const BubbleGameScreen(),
        ),
      ),
    );
  }
  @override
  void initState(){
    super.initState();
    final bloc=context.read<BubbleGameBloc>();
    audioService.playBackgroundMusic();
    _spawnTimer=Timer.periodic(const Duration(seconds:2),(timer){
      if(!bloc.state.isGameOver){
        context.read<BubbleGameBloc>().add(BubbleSpawned());
      }else{
        _spawnTimer.cancel();
      }
    });
    _collisionTimer=Timer.periodic(const Duration(milliseconds:200),(timer){
      if(!bloc.state.isGameOver){
        context.read<BubbleGameBloc>().add(CheckCollisions());
      }else{
        _collisionTimer.cancel();
        audioService.stopBackgroundMusic();
      }
    });
  }
  @override
  void dispose(){
    _spawnTimer.cancel();
    _collisionTimer.cancel();
    _factControllers.forEach((_,controller)=>controller.dispose());
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    // Variables to calculate the game body's offset
    final double appBarHeight=AppBar().preferredSize.height;
    final double topPadding=MediaQuery.of(context).padding.top;
    final double offsetTop=appBarHeight+topPadding;

    return Scaffold(
      backgroundColor:Colors.black,
//===AppBarImplementation===
      appBar:AppBar(
        backgroundColor:Colors.blue[800],
        elevation:4,
        automaticallyImplyLeading:false,
//1.LEFTSIDE:ScoreDisplay
        leadingWidth:120,
        leading:Padding(
          padding:const EdgeInsets.only(left:10.0),
          child:Center(
            child:BlocBuilder<BubbleGameBloc,BubbleGameState>(
                buildWhen:(previous,current)=>previous.score!=current.score||previous.isGameOver!=current.isGameOver,
                builder:(context,state){
                  if(state.isGameOver)return const SizedBox.shrink();
                  return Container(
                    padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
                    decoration:BoxDecoration(
                      color:Colors.white,
                      borderRadius:BorderRadius.circular(10),
                      border:Border.all(color:Colors.yellow,width:2),
                    ),
                    child:Text(
                      'Score: ${state.score}',
                      style:TextStyle(
                        fontSize:18,
                        fontWeight:FontWeight.bold,
                        color:Colors.blue[900],
                      ),
                    ),
                  );
                }
            ),
          ),
        ),
//2.MIDDLE:Title
        title:const Text(
          'Bubble Boom🫧',
          style:TextStyle(
            fontWeight:FontWeight.bold,
            color:Colors.white,
          ),
        ),
        centerTitle:true,
//3.RIGHTSIDE:ExitButton
        actions:[
          IconButton(
            icon:const Icon(Icons.exit_to_app_rounded,color:Colors.white),
            iconSize:30,
            onPressed:()=>_goHome(context),
          ),
          const SizedBox(width:8),
        ],
      ),
      body:SafeArea( // <--- WRAPPER ADDED HERE
        child:BlocConsumer<BubbleGameBloc,BubbleGameState>(
          listener:(context,state){
//Listenfornewfactsandstarttheanimationcontroller
            state.activePoppedFacts.forEach((bubbleId,factText){
              if(!_factControllers.containsKey(bubbleId)){
                final controller=AnimationController(
                  duration:const Duration(seconds:5),//Factdisplayduration
                  vsync:this,
                );
                _factControllers[bubbleId]=controller;
                controller.forward().then((_){
//TheClearPoppedFacteventrequirestheUniqueKeyofthebubble
                  context.read<BubbleGameBloc>().add(ClearPoppedFact(bubbleId));
                  controller.dispose();
                  _factControllers.remove(bubbleId);
                });
              }
            });
          },
          builder:(context,state){
//===GAMEOVERUI===
            if(state.isGameOver){
              return Center(
                child:Container(
                  padding:const EdgeInsets.all(40),
                  decoration:BoxDecoration(
                    color:Colors.lime,
                    borderRadius:BorderRadius.circular(15),
                    border:Border.all(color:Colors.red,width:6),
                  ),
                  child:Column(
                    mainAxisSize:MainAxisSize.min,
                    children:[
                      const Text(
                        '💥GAME OVER!💥',
                        style:TextStyle(fontSize:30,fontWeight:FontWeight.bold,color:Colors.red),
                      ),
                      const SizedBox(height:25),
                      Text(
                        'Final Score: ${state.score}',
                        style:const TextStyle(fontSize:28,color:Colors.black87),
                      ),
                      const SizedBox(height:40),
//1.PLAYAGAINButton
                      ElevatedButton.icon(
                        icon:const Icon(Icons.refresh),
                        label:const Text('PLAY AGAIN'),
                        onPressed:_startNewGame,
                        style:ElevatedButton.styleFrom(
                          backgroundColor:Colors.lightGreen,
                          padding:const EdgeInsets.symmetric(horizontal:30,vertical:15),
                          textStyle:const TextStyle(fontSize:20,fontWeight:FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height:10),
//2.BacktoHomeButton
                      TextButton(
                        onPressed:()=>_goHome(context),
                        child:const Text('Back to Home',style:TextStyle(color:Colors.blueGrey,fontSize:16)),
                      ),
                    ],
                  ),
                ),
              );
            }
//==========================
//===NORMALGAMEPLAYUI===
            return Stack(
              children:[
//Bubbles(2Dcircleswithpoppositioncalculation)
                ...state.bubbles.map((bubble){
                  return Positioned(
                    left:bubble.position.dx,
                    top:bubble.position.dy,
                    child:GestureDetector(
                      onTap:(){
//Calculatethepositionrelativetothewholescreen
                        final RenderBox renderBox=context.findRenderObject()as RenderBox;
                        final Offset stackOffset=renderBox.localToGlobal(Offset.zero);
//Calculatethecenterpointofthetappedbubble(GlobalPosition)
                        final Offset popPosition=Offset(
                          stackOffset.dx+bubble.position.dx+(bubble.size/2),
                          stackOffset.dy+bubble.position.dy+(bubble.size/2),
                        );
//Dispatcheventwithpositionforfloatingtext
                        context.read<BubbleGameBloc>().add(BubblePopped(bubble.id,popPosition));
                        audioService.playPopSound();
                      },
                      child:Container(
                        width:bubble.size,
                        height:bubble.size,
                        decoration:BoxDecoration(
                          color:bubble.color.withAlpha((255*0.7).round()),
                          shape:BoxShape.circle,
                          boxShadow:[
                            BoxShadow(
                              color:bubble.color.withAlpha((255*0.9).round()),
                              blurRadius:10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
//EnvironmentalFactDisplay(Animated,FloatingatPopPosition)
                ...state.activePoppedFacts.entries.map((entry){
                  final bubbleId=entry.key;
                  final factText=entry.value;
                  final Offset factPositionGlobal=state.activeFactPositions[bubbleId]??Offset(0,0);
                  if(!_factControllers.containsKey(bubbleId))return const SizedBox.shrink();
                  final controller=_factControllers[bubbleId]!;
                  const double cardWidth=220; // Increased width
                  const double cardHeight=120; // Increased height
                  const double floatOffset=30;//Floattext30pixelsabovepoppoint
                  return Positioned(
//Center the card horizontally on the tap point
                    left:factPositionGlobal.dx-(cardWidth/2),
//FIX:AdjusttheverticalpositionrelativetotheStack/body
                    top:factPositionGlobal.dy-offsetTop-floatOffset,
                    child:ScaleTransition(
                      scale:controller.drive(
                        Tween<double>(begin:0.5,end:1.1).chain(CurveTween(curve:Curves.elasticOut)),
                      ),
                      child:FadeTransition(
                        opacity:controller.drive(
                          Tween<double>(begin:1.0,end:0.0).chain(CurveTween(curve:const Interval(0.8,1.0))),
                        ),
                        child:Material(
                          elevation:6,
                          color:Colors.transparent,
                          child:Container(
                            width:cardWidth,
                            height:cardHeight,
                            padding:const EdgeInsets.all(10),
                            decoration:BoxDecoration(
                              color:Colors.cyanAccent.withOpacity(0.95), // Using CyanAccent color
                              borderRadius:BorderRadius.circular(10),
                              border:Border.all(color:Colors.blueAccent,width:2),
                            ),
                            child:Text(
                              factText,
                              textAlign:TextAlign.center,
                              style:const TextStyle(
                                fontSize:14,
                                color:Colors.black,
                                fontWeight:FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ), // <--- END SafeArea
    );
  }
}