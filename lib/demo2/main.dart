import 'package:flutter/material.dart';

import 'face_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // controller.forward();
      _counter++;
    });
  }
  late RelativeRectTween positionTween;
  late AnimationController controller;
  @override
  void initState() {
    super.initState();

  }

  final _myControl = MyProControl();

  Color _myColor = Colors.yellow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: MyColor(
        color: _myColor,
        color1: Colors.cyan,
        color2: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedSwitcher(
                  transitionBuilder : (Widget child, Animation<double> animation){
                    return FadeTransition(
                      key: ValueKey<Key?>(child.key),
                      opacity: animation,
                      child: child,
                    );
                  },
                duration: const Duration(milliseconds: 2000),
              child: _counter %2 == 0 ? Container( key : const Key("key1"),width: 100,height: 100,decoration:const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),) : Container( key : const Key("key2"),width: 100,height: 100,color: Colors.red,),
              ),

              AnimatedSwitcher(
                transitionBuilder : (Widget child, Animation<double> animation){
                  return FadeTransition(
                    key: ValueKey<Key?>(child.key),
                    opacity: animation,
                    child: child,
                  );
                },
                duration: const Duration(milliseconds: 2000),
                child: _counter %3 == 0 ? Container( key : const Key("key1"),width: 100,height: 100,decoration:const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),) : Container( key : const Key("key2"),width: 100,height: 100,color: Colors.red,),
              ),

              MyPro(control: _myControl,),
             const Foo(),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) {return FaceShowView() ;}));
          setState(() {
            _myColor = Colors.black;
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Foo extends StatelessWidget {
  const Foo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(width: 100,height: 100,color: MyColor.maybeOf(context)?.color??Colors.red,);
  }
}


class MyPro extends StatefulWidget {

  final MyProControl control;
  const MyPro({Key? key,required this.control}) : super(key: key);

  @override
  State<MyPro> createState() => _MyProState();
}

class _MyProState extends State<MyPro> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      builder: (context,_) {
        return Container(
          color: Colors.red,
          child: Column(children: [
            FlutterLogo(size: widget.control.count.value * 100 + 50),
            Slider(value: widget.control.count.value, onChanged: (value){
              widget.control.count.value = value;
            })
          ],),
        );
      }, listenable: Listenable.merge([
        widget.control.count
    ]),
    );
  }
}

class MyProControl {

  ValueNotifier<double> count = ValueNotifier(0.0);
}


class MyColor extends InheritedWidget{

  final Color color;
  final Color color1;
  final Color color2;


  const MyColor({super.key, required super.child,required this.color,required this.color1,required this.color2});

  static MyColor? maybeOf(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<MyColor>();
  }


  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
   return true;
  }

  // @override
  // bool updateShouldNotifyDependent(covariant InheritedModel<dynamic> oldWidget, Set<dynamic> dependencies) {
  //   print("dependencies==="+dependencies.toString());
  //   if(dependencies.contains(color1)) {
  //     return true;
  //   }
  // return false;
  // }

}