import 'package:flutter/material.dart';
import 'package:posapps/pages/penjualan.dart';

Widget _drawerHeader(String id) {
  return UserAccountsDrawerHeader(
    currentAccountPicture: ClipOval(
      child: Icon(
        Icons.person,
        color: Colors.white,
      ),
    ),
    accountName: Text('Demo Apps'),
    accountEmail: Text("Device ID: $id"),
  );
}

Widget _drawerItem({IconData icon, String text, GestureTapCallback onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(icon),
        Padding(
          padding: EdgeInsets.only(left: 25.0),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    onTap: onTap,
  );
}

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key key, this.id}) : super(key: key);
  final String id;

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _drawerHeader(widget.id),
          _drawerItem(
            icon: Icons.shopping_basket,
            text: 'Penjualan',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, PenjualanPage.routeName);
            },
          ),
          _drawerItem(
              icon: Icons.note_alt,
              text: 'Transaksi',
              onTap: () => print('Tap Transaksi')),
        ],
      ),
    );
  }
}
