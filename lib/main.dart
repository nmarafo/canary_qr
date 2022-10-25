
import 'package:canary_qr/utils/controller.dart';
import 'package:canary_qr/utils/remove_diacritics.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:string_validator/string_validator.dart';
import 'package:universal_html/html.dart' hide VoidCallback;
import 'package:url_launcher/url_launcher.dart';
import "package:universal_html/html.dart" as html hide VoidCallback;
import "package:http/http.dart" as http;

import 'alert_dialog.dart';

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
  ScreenshotController controller = ScreenshotController();
  Uint8List? bytes;

  final ScrollController scrollController = ScrollController();
  final ScrollController scrollControllerHorizontal = ScrollController();

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
        padding: const EdgeInsets.all(10),
        child: TextButton(
          onPressed: _launchUrl,
          child: const Text('Norberto Martín Afonso'),
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

  getData(FilePickerResult result) async {

    final file = result.files.first;
    final fileReadStream = file.readStream;
    if (fileReadStream == null) {
      throw Exception('Cannot read file from null stream');
    }
    final stream = await http.ByteStream(fileReadStream).toBytes();
    c.imageData.value=Image.memory(stream);

    document.exitFullscreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: SingleChildScrollView(
        controller: scrollController,
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(const Size(1000,800)),
          child: SingleChildScrollView(
            controller: scrollControllerHorizontal,
            scrollDirection: Axis.horizontal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 100,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 100,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(5),
                            child: Text('Agregar Logo'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Obx(()=>Switch(
                              value: c.light.value,
                              activeColor: Colors.green,
                              onChanged: (bool value) {
                                c.light.value = value;
                              },
                            )),
                          ),
                          Obx(() {
                            return c.light.value ? Padding(
                              padding: const EdgeInsets.all(5),
                              child: MaterialButton(
                                  onPressed: () async{
                                    bool _hasValidMime = false;
                                    String? _path;
                                    FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
                                      withReadStream: true,
                                      withData: false,
                                      type:FileType.custom,
                                      allowedExtensions: ['jpg','jpeg','png'],
                                    );

                                    _path=result?.files.first.extension;
                                    if(_path=='jpg'||_path=='jpeg'||_path=='png'){
                                      _hasValidMime=true;
                                    }

                                    if (result != null&&_hasValidMime) {
                                      await getData(result);
                                    }else if(result == null){

                                    }
                                    else if(!_hasValidMime){
                                      showDialog(context: context,
                                        builder: (BuildContext context) {
                                          return MyAlertDialog(
                                            tittle: 'unsupported_format'.tr,
                                            description: 'unsupported_format_description'.tr,
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: c.myIcon.value
                              ),
                            ) : const SizedBox(height: 60,);
                          })
                        ],
                      ),
                    ),
                    Obx(() {
                      return c.light.value ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: MyWidget()
                      ) : const SizedBox(height: 100,width: 100,);
                    })
                  ],
                ),

                c.dataForm=="" ? Container() :
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(20),
                        child: Screenshot(
                          controller: controller,
                          child: MyCapturedWidget(),
                        )
                    ),
                    //if (bytes != null) buildImage(bytes!),
                    ElevatedButton(
                      child: const Text('Guardar código QR'),
                      onPressed: () {
                        controller.capture(delay: const Duration(milliseconds: 10)).then((capturedImage) {
                          //ShowCapturedWidget(context, capturedImage!);
                          exportImage(capturedImage);
                        });
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class MyCapturedWidget extends StatelessWidget {
  MyCapturedWidget({Key? key}) : super(key: key);

  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
          decoration:c.light.value ? BoxDecoration(
            image: DecorationImage(
                image: c.imageData.value.image,
                fit: BoxFit.contain
            ),
          ) : null,
          child: QrImage(
            data: c.dataForm,
            version: QrVersions.auto,
            size: 320,
          )
      );
    });
  }
}


class MyWidget extends StatelessWidget {
  MyWidget({Key? key}) : super(key: key);

  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Obx((){
        return c.imageData.value;
      }),
    );
  }
}

Future<dynamic> ShowCapturedWidget(
    BuildContext context, Uint8List capturedImage) {
  return showDialog(
    useSafeArea: false,
    context: context,
    builder: (context) => Scaffold(
      appBar: AppBar(
        title: Text("Captured widget screenshot"),
      ),
      body: Center(
          child: capturedImage != null
              ? Image.memory(capturedImage)
              : Container()),
    ),
  );
}