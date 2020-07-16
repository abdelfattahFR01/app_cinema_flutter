import 'package:app_cinema/GlobalVariables.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class SallesPage extends StatefulWidget {
  dynamic cinema;

  SallesPage(this.cinema);

  @override
  _SallesPageState createState() => _SallesPageState();
}

class _SallesPageState extends State<SallesPage> {
  List<dynamic> listSalles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salles de ${widget.cinema['name']}'),
      ),
      body: Center(
        child: (this.listSalles == null)
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: this.listSalles == null ? 0 : this.listSalles.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              color: Colors.deepOrange,
                              child: Text(this.listSalles[index]['name']),
                              onPressed: () {
                                loadProjection(this.listSalles[index]);
                              },
                            ),
                          ),
                        ),
                        if (this.listSalles[index]['projections'] != null)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Image.network(
                                  GlobalData.host +
                                      "/imageFilm/${this.listSalles[index]['currentProjection']['film']['id']}",
                                  width: 150,
                                ),
                                Column(
                                  children: <Widget>[
                                    ...(this.listSalles[index]['projections']
                                            as List<dynamic>)
                                        .map((projection) {
                                      return RaisedButton(
                                        color: (this.listSalles[index]
                                                        ['currentProjection']
                                                    ['id'] ==
                                                projection['id']
                                            ? Colors.deepOrange
                                            : Colors.amber),
                                        child: Text(
                                          "${projection['seance']['heureDebut']}(${projection['film']['duree']}, Prix=${projection['prix']})",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
                                        ),
                                        onPressed: () {
                                          loadTickets(projection,
                                              this.listSalles[index]);
                                        },
                                      );
                                    })
                                  ],
                                )
                              ],
                            ),
                          ),
                        if (this.listSalles[index]['currentProjection'] !=
                                null &&
                            this.listSalles[index]['currentProjection']
                                    ['listTickets'] !=
                                null &&
                            (this
                                    .listSalles[index]['currentProjection']
                                        ['listTickets']
                                    .length >
                                0))
                          Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text("Nombre de places dispo:${this.listSalles[index]['currentProjection']['nombrePlacesDisponibles']} ")
                                ],
                              ),
                             /* Container(
                                padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
                                child: TextField(decoration: InputDecoration(hintText: 'votre nom'),),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
                                child: TextField(decoration: InputDecoration(hintText: 'code payement'),),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(6, 2, 6, 3),
                                child: TextField(decoration: InputDecoration(hintText: 'nombre tickets'),),
                              ),
                              Container(
                                width: double.infinity,
                                child: RaisedButton(
                                  color: Colors.lightGreen,

                                  child: Text("Reservez des places"),
                                  onPressed: (){

                                  },
                                ),
                              ),*/
                              Wrap(
                                children: <Widget>[
                                  ...this
                                      .listSalles[index]['currentProjection']
                                  ['listTickets']
                                      .map((ticket) {
                                    if(ticket['taken']==false)
                                      return Container(
                                        width: 50,
                                        padding: EdgeInsets.all(2),
                                        child: RaisedButton(

                                          color: Colors.green,
                                          child: Text("${ticket['place']['numero']}",style: TextStyle(color: Colors.white,fontSize: 12),),
                                          onPressed: (){


                                          },
                                        ),
                                      );
                                    else return Container();
                                  })
                                ],
                              )
                            ],
                          )

                      ],
                    ),
                  );
                }),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadSalles();
  }

  void loadSalles() {
    String url = this.widget.cinema['_links']['salles']['href'];
    http.get(url).then((resp) {
      setState(() {
        this.listSalles = json.decode(resp.body)['_embedded']['salles'];
      });
    }).catchError((err) {
      print(err);
    });
  }

  void loadProjection(salle) {
    /*String url=salle['_links']['projections']['href'].toString().replaceAll("{?projections}", "?projection=p1");*/
    String url =
        GlobalData.host + "/salles/${salle['id']}/projections?projection=p1";
    print(url);
    http.get(url).then((resp) {
      setState(() {
        salle['projections'] =
            json.decode(resp.body)['_embedded']['projectionFilms'];

        salle['currentProjection'] = salle['projections'][0];
        salle['currentProjection']['listTickets'] = [];
        print(salle['projections']);
      });
    }).catchError((err) {
      print(err);
    });
  }

  void loadTickets(projection, salle) {
    String url = projection['_links']['tickets']['href']
        .toString()
        .replaceAll("{?projection}", "?projection=ticketproj");
    print(url);
    http.get(url).then((resp) {
      setState(() {
        projection['listTickets'] =
            json.decode(resp.body)['_embedded']['tickets'];
        print(projection['listTickets']);
        salle['currentProjection'] = projection;
        projection['nombrePlacesDisponibles']=nombrePlaceDisponible(projection);
      });
    }).catchError((err) {
      print(err);
    });
  }
  nombrePlaceDisponible(projection){
    int nombre=0;
    for(int i=0;i<projection['tickets'].length;i++){
      if(projection['tickets'][i]['taken']==false)
        nombre++;
    }
    return nombre;
  }
}
