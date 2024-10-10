import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icon.dart';
import 'package:provider/provider.dart';
import 'package:tr_guide/componenets/network_utility.dart';
import 'package:tr_guide/core/constants.dart';
import 'package:tr_guide/core/providers/user_provider.dart';
import 'package:tr_guide/models/autocomplete_prediction.dart';
import 'package:tr_guide/models/place_auto_complete_response.dart';
import 'package:tr_guide/presentation/widgets/location_list_tile.dart';
import 'package:tr_guide/services/firestore_methods.dart';
import 'package:tr_guide/utils/colors.dart';
import 'package:tr_guide/utils/utils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  List<AutocompletePrediction> placePredictions = [];
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? selectedLocation;

  // autocomplete for the locations
  void placeAutocomplete(String query) async {
    Uri uri =
        Uri.https("maps.googleapis.com", 'maps/api/place/autocomplete/json', {
      "input": query,
      "key": apiKey, //myAPI key
    });

    String? response = await NetworkUtility.fetchUrl(uri);

    if (response != null) {
      PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutoCompleteResult(response);
      if (result != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }

  // Select Image
  Future<void> _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take a photo'),
              onPressed: () async {
                Navigator.pop(context);
                Uint8List file = await pickImage(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose from Gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Post Image
  void postImage(String uid, String username, String profImage) async {
    if (_file == null) {
      showSnackBar(context, 'Please select an image before posting.');
      return;
    }

    if (selectedLocation == null) {
      showSnackBar(context, 'Please select a location.');
      return;
    }

    setState(() {
      isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
        _captionController.text,
        _file!,
        uid,
        username,
        profImage,
        location: selectedLocation!,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          showSnackBar(context, 'Posted!');
        }
        clearImage();
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, err.toString());
    }
  }

  // Clear Image
  void clearImage() {
    setState(() {
      _file = null;
      _captionController.clear();
      _locationController.clear();
      selectedLocation = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _captionController.dispose();
    _locationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: defaultPadding),
          child: IconButton(
            icon: const LineIcon.times(),
            color: redColor,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: const Text(
          "New Post",
          style: TextStyle(color: redColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _selectImage(context),
                child: _file == null
                    ? Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: MemoryImage(_file!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: "Share your travel experience!",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  placeAutocomplete(value);
                },
                textInputAction: TextInputAction.search,
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: "Search location...",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.search, color: Colors.grey),
                ),
              ),
              // const Divider(
              //   color: Colors.grey,
              //   thickness: 1,
              // ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: placePredictions.length,
                itemBuilder: (context, index) => LocationListTile(
                  location: placePredictions[index].description!,
                  press: () {
                    setState(() {
                      _locationController.text =
                          placePredictions[index].description!;
                      selectedLocation = placePredictions[index].description;
                      placePredictions.clear();
                    });
                  },
                ),
              ),
              const SizedBox(height: 175),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      try {
                        final user = userProvider.getUser;

                        postImage(
                          user!.uid,
                          user.name,
                          user.photoUrl,
                        );
                      } catch (e) {
                        // Handle the exception (e.g., show an error message)
                        showSnackBar(context,
                            'User data is not available. Please try again later.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 14),
                    ),
                    child: const Text(
                      "Post",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
