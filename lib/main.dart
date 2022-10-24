
import 'package:canary_qr/utils/controller.dart';
import 'package:canary_qr/utils/remove_diacritics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:universal_html/html.dart" as html;
import 'package:widgets_to_image/widgets_to_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(Controller());
    return GetMaterialApp(
      title: 'Canary QR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Canary_QR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final Controller c = Get.find();
  WidgetsToImageController controller = WidgetsToImageController();
  Uint8List? bytes;
  Widget buildImage(Uint8List bytes) => SizedBox(width: 100,height:100,child:Image.memory(bytes));

  final Uri _url = Uri.parse('https://mobile.twitter.com/norbertomartnaf/');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  List<Widget> aboutBoxChildren (VoidCallback function) {
    return <Widget>[
      const SizedBox(
        height: 20,
      ),
      Padding(
        padding: EdgeInsets.all(10),
        child: TextButton(
          onPressed: _launchUrl,
          child: Text('Norberto Martín Afonso'),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      /*const Padding(
        padding: EdgeInsets.all(10),
        child: Text('powered by Flame Engine and Rive'),
      ),*/
    ];
  }

  void exportImage(Uint8List? bytes) async{
    //File file2 = File('myImage.jpg');             // <-- 2
    //file2.writeAsBytesSync(bytes!);
    //final json = jsonEncode(c.ruleta);

// prepare
    //final bytes = utf8.encode(json);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'Mi código QR.png';
    html.document.body?.children.add(anchor);

// download
    anchor.click();

// cleanup
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 50),
              child: IconButton(
                  onPressed: (){
                    showAboutDialog(
                      context: context,
                      applicationName: 'Canary QR',
                      applicationVersion: '1.0.0',
                      //applicationLegalese: '© 2022 Norberto Martín Afonso',
                      children: aboutBoxChildren(_launchUrl),
                    );
                  },
                  icon: const Icon(Icons.info_outline,color: Colors.white,)
              ),
            ),
          ]
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Introduzca la url que desea convertir en código QR:',
            ),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              onChanged: () {
                //Form.of(primaryFocus!.context!)!.save();
              },
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ConstrainedBox(
                          constraints: BoxConstraints.tight(const Size(400, 30)),
                          child: const Text("mínimo de 4 caracteres",textAlign: TextAlign.center,)
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ConstrainedBox(
                          constraints: BoxConstraints.tight(const Size(400, 50)),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.keyboard),
                            ),
                            onSaved: (String? value) {
                              if(value!=null){
                                //Navigator.pop(context);
                                _formKey.currentState?.reset();
                                String valueFinal=removeDiacritics(value.toLowerCase());
                                print(valueFinal);
                                c.dataForm=valueFinal;
                              }
                            },
                            validator: (String? value) {
                              bool isValid=false;
                              bool hasTittle=false;
                              if(isLength(value!,1,200)&&!hasTittle){
                                isValid=true;
                              }

                              if (!isValid) {
                                return 'No es válido';
                              }
                              return null;
                            },
                          )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        child: const Text('Generar QR'),
                        onPressed: (){
                          if(_formKey.currentState!.validate()){
                            _formKey.currentState?.save();
                            setState(() {

                            });
                          }
                        },
                      ),
                    ),
                  ]
              ),
            ),

            c.dataForm=="" ? Container() :
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: WidgetsToImage(
                    controller: controller,
                    child: QrImage(
                      data: c.dataForm,
                      version: QrVersions.auto,
                      size: 200.0,
                    )
                  ),
                ),
                //if (bytes != null) buildImage(bytes!),
                ElevatedButton(
                  child: const Text('Guardar código QR'),
                  onPressed: () async{
                    final bytes = await controller.capture();
                    setState(() {
                      this.bytes = bytes;
                      exportImage(bytes);
                    });
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
