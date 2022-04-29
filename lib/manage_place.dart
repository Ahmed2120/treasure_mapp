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
    return ListView.builder(
      itemCount: helper.places.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(helper.places[index].id.toString()),
          onDismissed: (direction){
            String strName = helper.places[index].name;
            Provider.of<Controller>(context, listen: false).deleteMarker(helper.places[index].id!);
            helper.deletePlace(helper.places[index]);

            setState(() {
              helper.places.removeAt(index);
            });
            Provider.of<Controller>(context, listen: false).getData();
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$strName deleted")));
          },
          child: ListTile(
            title: Text(helper.places[index].name),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: (){
                PlaceDialog dialog = PlaceDialog(helper.places[index], false);
                showDialog(context: context, builder: (context) => dialog.buildDialog(context));
              },
            ),
          ),
        );
      },
    );
  }
}

