import 'package:flutter/material.dart';
import 'package:flutter_app5/screens/crop.dart';
import 'dart:io';
import 'package:flutter_app5/services/auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: Text('Image Upload '),
          backgroundColor: Colors.pink[400],
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('logout'),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ],
        ),
        body: ImageInput(),
      ),
    );
  }
}

class ImageInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImageInput();
  }
}

void success (BuildContext context)
{
  var alert = AlertDialog(
    title: Text("Success",textAlign: TextAlign.center,),
    content: Text("Your image is under process !!",textAlign: TextAlign.center,),
    actions: <Widget>[
      Container(child: RaisedButton(child: Text('Ok',style: TextStyle(fontSize: 15.0),),elevation: 5,
        splashColor: Colors.pinkAccent,
        color: Colors.black,
        onPressed:  () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        },
      ),alignment: Alignment.center,
      )

    ],
  );
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;}
  );
}


class _ImageInput extends State<ImageInput> {
  // To store the file provided by the image_picker
  File _imageFile;
  bool _isUploading = false;
  String _uploadedFileURL;
  // To track the file uploading state
  void _getImage(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
    setState(() {
      _imageFile = image;
    });
    // Closes the bottom sheet

    Navigator.pop(context);
  }
  Future _uploadImage(File image) async {
    setState(() {
      _isUploading = true;
    });
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('images/${Path.basename(_imageFile.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_imageFile);
    await uploadTask.onComplete;
    success(context);
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });

  }

  void success (BuildContext context)
  {
    var alert = AlertDialog(
      title: Text("Success",textAlign: TextAlign.center,),
      content: Text("Your image is under process !!",textAlign: TextAlign.center,),
      actions: <Widget>[
        Container(child: RaisedButton(child: Text('Ok',style: TextStyle(fontSize: 15.0),),elevation: 5,
          splashColor: Colors.pinkAccent,
          color: Colors.black,
          onPressed:  () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),alignment: Alignment.center,
        )

      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;}
    );
  }
  void failed (BuildContext context)
  {
    var alert = AlertDialog(
      title: Text("Failed",textAlign: TextAlign.center,),
      content: Text("We could not process your request. Please try again !",textAlign: TextAlign.center,),
      actions: <Widget>[
        Container(child: RaisedButton(child: Text('Ok',style: TextStyle(fontSize: 15.0),),elevation: 5,
          splashColor: Colors.pinkAccent,
          color: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => crop1()),
            );
          },
        ),alignment: Alignment.center,
        )

      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }


  void _openImagePickerModal(BuildContext context) {
    final flatButtonColor = Theme.of(context).primaryColor;
    print('Image Picker Modal Called');
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Camera'),
                  onPressed: () {
                    _getImage(context, ImageSource.camera);
                  },
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Gallery'),
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }
  Widget _buildUploadBtn() {
    Widget btnWidget = Container();
    if (_isUploading) {
      // File is being uploaded then show a progress indicator
      btnWidget = Container(
          margin: EdgeInsets.only(top: 10.0),
          child: CircularProgressIndicator());
    } else if (!_isUploading && _imageFile != null) {
      // If image is picked by the user then show a upload btn
      btnWidget = Container(
        margin: EdgeInsets.only(top: 10.0),
        child: RaisedButton(
          child: Text('Upload'),
          onPressed: () {
           _uploadImage(_imageFile);
          },
          color: Colors.pinkAccent,
          textColor: Colors.white,
        ),
      );
    }
    return btnWidget;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
            child: OutlineButton(
              onPressed: () => _openImagePickerModal(context),
              borderSide:
              BorderSide(color: Theme
                  .of(context)
                  .accentColor, width: 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.camera_alt),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text('Add Image'),
                ],
              ),
            ),
          ),
          _imageFile == null
              ? Text('Please pick an image')
              : Image.file(
            _imageFile,
            fit: BoxFit.cover,
            height: 300.0,
            alignment: Alignment.topCenter,
            width: MediaQuery
                .of(context)
                .size
                .width,
          ),
          _buildUploadBtn(),
        ],
      ),
    );
  }}