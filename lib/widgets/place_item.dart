import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasure_mapp/widgets/place_dialog.dart';

import '../model/place.dart';
import '../screens/photo_screen.dart';
import '../services/controller.dart';

class PlaceItem extends StatelessWidget {
  const PlaceItem({
    Key? key, required this.place,
  }) : super(key: key);

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric( vertical: 4 ,horizontal: 6),
      decoration: const BoxDecoration(

      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GridTile(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PhotoScreen(place.image, place.id!))),
            child: Hero(
                tag: place.id!,
                child: FadeInImage(
                  placeholder: const AssetImage('assets/images/place.jpg'),
                  image: FileImage(
                    File(place.image),
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
                  showDialog(context: context, builder: (context) => PlaceDialog(place, false));
                },
              ),
            ),
            title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25), textAlign: TextAlign.center,),
          trailing: Row(
            children: [
              Icon(Icons.location_on_outlined),
              Text(place.city, style: const TextStyle(color:Colors.white, fontSize: 18))
            ],
          ),
          ),
        ),
      ),
    );
  }
}