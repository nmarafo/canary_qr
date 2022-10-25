
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Controller extends GetxController{
  String dataForm="";
  var imageData=Image.asset('imagen.png').obs;
  var myIcon=const Icon(Icons.drive_folder_upload,size: 50,).obs;
  var light=false.obs;
}