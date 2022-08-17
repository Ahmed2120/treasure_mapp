import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasure_mapp/photo_screen.dart';
import 'package:treasure_mapp/place.dart';
import 'controller.dart';
import 'place_dialog.dart';
import 'dbhelper.dart';
import 'package:geocoding/geocoding.dart';


class ManagePlaces extends StatelessWidget {
  const ManagePlaces({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Places'),
      ),
      body: const PlaceList(),
    );
  }
}

class PlaceList extends StatefulWidget {
  const PlaceList({Key? key}) : super(key: key);

  @override
  _PlaceListState createState() => _PlaceListState();
}

class _PlaceListState extends State<PlaceList> {

  DbHelper helper = DbHelper();



  getCity(Place place) async{
    final address = await placemarkFromCoordinates(place.lat, place.lon);
    return address.first.country;
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<Controller>(
      builder: (context, controller, _)=>
          controller.places.isEmpty ?
              Center(
                child: Text('No Places Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: const Color(0xFF827773).withOpacity(0.7))),
              ):
          ListView.builder(
        itemCount: controller.places.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(controller.places[index].id.toString()),
            background: Container(
              color: Theme.of(context).errorColor,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 40,
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) {
              return showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Are you sre?'),
                    content: const Text('You want to delete this place'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('No')),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Yes')),
                    ],
                  ));
            },
            onDismissed: (direction){
              String strName = controller.places[index].name;
              Provider.of<Controller>(context, listen: false).deleteMarker(controller.places[index].id!);
              helper.deletePlace(controller.places[index]);

              setState(() {
                controller.places.removeAt(index);
              });
              Provider.of<Controller>(context, listen: false).getData();
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$strName deleted", textAlign: TextAlign.center,), duration: Duration(milliseconds: 500),));
            },
            child: Container(
              height: 220,
              margin: const EdgeInsets.symmetric( vertical: 4 ,horizontal: 6),
              decoration: const BoxDecoration(

              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GridTile(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PhotoScreen(controller.places[index].image, controller.places[index].id!))),
                    child: Hero(
                      tag: controller.places[index].id!,
                      child: FadeInImage(
                        placeholder: const AssetImage('assets/images/place.jpg'),
                        image: FileImage(
                          File(controller.places[index].image),
                        ),
                        fit: BoxFit.cover,
                      )
                    ),
                  ),
                  footer: GridTileBar(
                    backgroundColor: const Color(0xFF827773).withOpacity(0.5),
                    leading: Consumer<Controller>(
                      builder: (ctx, product, _) => IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: (){
                              showDialog(context: context, builder: (context) => PlaceDialog(controller.places[index], false));
                            },
                      ),
                    ),
                    title: Text(controller.places[index].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25), textAlign: TextAlign.center,),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

