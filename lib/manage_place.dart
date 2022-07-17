import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller.dart';
import 'place_dialog.dart';
import 'dbhelper.dart';


class ManagePlaces extends StatelessWidget {
  const ManagePlaces({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Places'),
      ),
      body: PlaceList(),
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


  @override
  Widget build(BuildContext context) {
    return Consumer<Controller>(
      builder: (context, controller, _)=> ListView.builder(
        itemCount: controller.places.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(controller.places[index].id.toString()),
            background: Container(
              color: Theme.of(context).errorColor,
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 40,
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) {
              return showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Are you sre?'),
                    content: Text('Are you sre?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('No')),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Yes')),
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$strName deleted")));
            },
            child: Container(
              height: 200,
              margin: EdgeInsets.symmetric( vertical: 4),
              decoration: BoxDecoration(
                image: DecorationImage(
                  opacity: 0.7,
                  fit: BoxFit.cover,
                  image: FileImage(
                    File(controller.places[index].image),
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GridTile(
                  child: GestureDetector(
                    // onTap: () => Navigator.of(context).pushNamed(ProductDetail.routeName, arguments: product.id),
                    child: FadeInImage(
                      placeholder: AssetImage('assets/images/place.jpg'),
                      image: FileImage(
                        File(controller.places[index].image),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  footer: GridTileBar(
                    backgroundColor: Colors.black45,
                    leading: Consumer<Controller>(
                      builder: (ctx, product, _) => IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: (){
                              PlaceDialog dialog = PlaceDialog(controller.places[index], false);
                              showDialog(context: context, builder: (context) => PlaceDialog(controller.places[index], false));
                            },
                      ),
                    ),
                    title: Text(controller.places[index].name, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                  ),
                ),
              ),
              // child: ListTile(
              //   title: Text(controller.places[index].name, style: TextStyle(fontWeight: FontWeight.bold),),
              //   trailing: IconButton(
              //     icon: const Icon(Icons.edit),
              //     onPressed: (){
              //       PlaceDialog dialog = PlaceDialog(controller.places[index], false);
              //       showDialog(context: context, builder: (context) => dialog.buildDialog(context));
              //     },
              //   ),
              // ),
            ),
          );
        },
      ),
    );
  }
}

