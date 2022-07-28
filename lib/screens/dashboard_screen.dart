import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptocurrency_flutter/ChatScrenns/chat_provider.dart';
import 'package:cryptocurrency_flutter/banner_image.dart';
import 'package:cryptocurrency_flutter/component/market_component.dart';
import 'package:cryptocurrency_flutter/component/trending_component.dart';
import 'package:cryptocurrency_flutter/main.dart';
import 'package:cryptocurrency_flutter/model/coin_list_model.dart';
import 'package:cryptocurrency_flutter/model/dashboard_model.dart';
import 'package:cryptocurrency_flutter/model/user_model.dart';
import 'package:cryptocurrency_flutter/network/rest_api.dart';
import 'package:cryptocurrency_flutter/screens/derivatives_screen.dart';
import 'package:cryptocurrency_flutter/screens/exchanges_screen.dart';
import 'package:cryptocurrency_flutter/utils/app_colors.dart';
import 'package:cryptocurrency_flutter/utils/app_common.dart';
import 'package:cryptocurrency_flutter/utils/app_constant.dart';
import 'package:cryptocurrency_flutter/widgets/app_scaffold.dart';
import 'package:cryptocurrency_flutter/widgets/banner_widget.dat.dart';
import 'package:cryptocurrency_flutter/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AsyncMemoizer<DashboardResponse> asyncMemoizer = AsyncMemoizer();
  final _fireStore = FirebaseFirestore.instance;

  int page = 1;

  bool isLastPage = false;
  bool isReady = false;

  List<CoinListModel> mainList = [];
  UserModel userModel = UserModel();
  final _auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppScaffold(
        appBar: AppBar(
          title: Text('lbl_dashboard'.translate, style: boldTextStyle(size: 22)),
          automaticallyImplyLeading: false,
          actions: [

            IconButton(onPressed: ()async{

                if (appStore.isLoggedIn && !appStore.isSocialLogin) {
                  log('User is  founded');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  TypeChatScreen()),
                  );

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(  SnackBar(content: Text('Before going to chat screen .You should need to login first!'),));
                  log('User is not found');
                  // log('User uid is not found: ${appStore.uid.validate()}');

                }



            }, icon: Icon(Icons.chat_outlined,color:themePrimaryColor)),
            IconButton(
              icon: Icon(Icons.import_export_outlined),
              onPressed: () {
                ExchangesScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Scale);
              },
            ).withTooltip(msg: "lbl_exchanges".translate),
            IconButton(
              icon: Icon(Icons.stacked_line_chart_outlined),
              onPressed: () {
                DerivativesScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Scale);
              },
            ).withTooltip(msg: "lbl_derivatives".translate),

          ],
        ),
        body: TimerWidget(
          initialDelay: 0,
          duration: 10.seconds,
          function: () {
            setState(() {});
          },
          child: FutureBuilder<DashboardResponse>(
            future: dashboardStream(currency: appStore.mSelectedCurrency!.cc.validate()),
            initialData: getStringAsync(SharedPreferenceKeys.TRENDING_DATA).isEmpty ? null : getCachedUserDashboardData(),
            builder: (context, snap) {
              if (snap.hasData) {
                return RefreshIndicator(
                  color: themePrimaryColor,
                  backgroundColor: context.cardColor,
                  triggerMode: RefreshIndicatorTriggerMode.onEdge,
                  onRefresh: () async {
                    setState(() {});
                    await Future.delayed(Duration(seconds: 2));
                  },
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 36),
                    physics: BouncingScrollPhysics(),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [





                        // Banner list
                        StreamBuilder(
                            stream: _fireStore.collection('Banners').snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                              if(snapshot.hasData){
                                return Container(

                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  height: 110,
                                  child: ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children:
                                    snapshot.data!.docs.map((DocumentSnapshot document) {
                                      Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;

                                      return   Column(children: [

                                        Text(data['BannerName'] ??'Banner title',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                        SizedBox(height: 10,),
                                        Container(

                                            decoration:BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color:themePrimaryColor,width: 2)
                                            ),
                                            margin: EdgeInsets.symmetric(horizontal: 8),

                                            width: 300,
                                            height: 70,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: Image.network(
                                                  data['BannerImage'] ?? b2,
                                                  fit: BoxFit.cover
                                              ),
                                            )),
                                      ],);
                                      // ImageBannerWidget(ImageUrl:data['ImageUrl'],)

                                    }).toList(),
                                  ),
                                );
                              }
                              return Center(child: CircularProgressIndicator(color: Colors.deepOrange),);
                            }),


                        /// Crypto coin list

                        StreamBuilder(
                            stream: _fireStore.collection('Crypto').snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                              if(snapshot.hasData){
                                return Container(

                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  height: 110,
                                  child: ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children:
                                    snapshot.data!.docs.map((DocumentSnapshot document) {
                                      Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;

                                      return   Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [


                                        Container(
                                            decoration:BoxDecoration(
                                                borderRadius: BorderRadius.circular(100),
                                                border: Border.all(color:themePrimaryColor,width: 2)
                                            ),
                                            margin: EdgeInsets.symmetric(horizontal: 8),

                                            width: 80,
                                            height: 80,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(100.0),
                                              child: Image.network(
                                                  data['cryptoImage'] ?? b2,
                                                  fit: BoxFit.cover
                                              ),
                                            )),
                                        Text( data['cryptoName'] ??'Crypto name',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                        Text(data['cryptoPrice'] ??'Crypto Price',style: TextStyle(fontSize: 14,fontWeight: FontWeight.normal),),
                                      ],);
                                      // ImageBannerWidget(ImageUrl:data['ImageUrl'],)

                                    }).toList(),
                                  ),
                                );
                              }
                              return Center(child: CircularProgressIndicator(color: Colors.deepOrange),);
                            }),


                        // other widgets

                        TrendingComponent(data: snap.data!.trendingCoins!),
                        8.height,
                        MarketComponent(mainList: snap.data!.coinModel.validate()),
                      ],
                    ),
                  ),
                );
              }
              return snapWidgetHelper(snap, loadingWidget: LoaderWidget());
            },
          ),
        )
      ),
    );
  }
}
/*
      Container(
                          margin: EdgeInsets.only(top: 20),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          // color: Colors.blueGrey,

                          height: 120,
                          child:ListView.builder(
                            itemCount: 6,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context,index){
                             return
                              Column(children: [

                                Container(
                                  decoration:BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(color:themePrimaryColor,width: 2)
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 8),

                                     width: 80,
                                     height: 80,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100.0),
                                      child: Image.network(
                                        b2,
                                          fit: BoxFit.cover
                                      ),
                                    )),
                                Text('Crypto name',style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal),),
                                Text('Crypto Price',style: TextStyle(fontSize: 14,fontWeight: FontWeight.normal),),
                              ],);

    }
                          ),
                        ),
*/
// class NoonLoopingDemo extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Noon-looping carousel demo')),
//       body: Container(
//           child: CarouselSlider(
//             options: CarouselOptions(
//               aspectRatio: 2.0,
//               enlargeCenterPage: true,
//               enableInfiniteScroll: false,
//               initialPage: 2,
//               autoPlay: true,
//             ),
//             items: imageSliders,
//           )),
//     );
//   }
// }