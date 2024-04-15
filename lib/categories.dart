import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';


import 'dart:convert';
import 'adapters/category_model.dart';
import 'adapters/channels_model.dart';
import 'channels_list.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {

  late Box<ChannelModel> channelsBox;
  late BannerAd bannerAdTop;
  late BannerAd bannerAdBottom;
  bool isLoadedTop = false;
  bool isLoadedBottom = false;
  var adUnitTop =
      "ca-app-pub-9354755118881714/1486080631"; // Change this to your top ad unit ID
  var adUnitBottom =
      "ca-app-pub-9354755118881714/4631118721";
  @override
  void initState() {

    super.initState();
    channelsBox = Hive.box<ChannelModel>('channels');
    _initChannels();
    initBannerAds();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initBannerAds() {
    bannerAdTop = BannerAd(
        adUnitId: adUnitTop,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (ad) {
          setState(() {
            isLoadedTop = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print("Failed to load top banner ad: ${error.message}");
        }));
    bannerAdTop.load();

    bannerAdBottom = BannerAd(
        adUnitId: adUnitBottom,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (ad) {
          setState(() {
            isLoadedBottom = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print("Failed to load bottom banner ad: ${error.message}");
        }));
    bannerAdBottom.load();
  }

  Future<void> _initChannels() async {
    // Check if Nigerian channels are already in the Hive box
    if (channelsBox.values
        .any((channel) => channel.country == 'Canada')) {
      return;
    }

    // If not, fetch Nigerian channels from Firebase and add them to the Hive box
    await fetchUSAChannelsFirebase();
    setState(() {});
  }

  Future<List<ChannelModel>> fetchUSAChannels() async {
    try {
      List<ChannelModel> usaChannels = [];

      // Iterate through the Hive box
      for (var i = 0; i < channelsBox.length; i++) {
        ChannelModel channel = channelsBox.getAt(i)!;
        if (channel.country == 'Canada') {
          usaChannels.add(channel);
        }
      }

      return usaChannels;
    } catch (e) {
      print("Error fetching channels: $e");
      return [];
    }
  }

  // ... Other methods ...

  Future<List<QueryDocumentSnapshot>> fetchUSAChannelsFirebase() async {
    try {
      Box<ChannelModel> channelsBox = Hive.box<ChannelModel>('channels');

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('channels')
          .where('country', isEqualTo: 'Canada')
          .get();

      List<QueryDocumentSnapshot> documents = snapshot.docs;

      for (QueryDocumentSnapshot document in documents) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

        if (data != null) {
          String channelId = data['id'] ?? '';
          String channelName = data['name'] ?? '';
          String channelCountry = data['country'] ?? '';
          String channelLogo = data['logo'] ?? '';
          String channelStreamingLink = data['streamingLink'] ?? '';
          List<String> categories = List<String>.from(data['categories'] ?? []); // Extract category array

          // Save the data in the Hive channel box
          channelsBox.put(
            channelId,
            ChannelModel(
              id: channelId,
              name: channelName,
              country: channelCountry,
              logo: channelLogo,
              streamingLink: channelStreamingLink,
              categories: categories, // Assign category array
            ),
          );
        }
      }

      return documents;
    } catch (e) {
      print("Error fetching channels: $e");
      return [];
    }
  }




  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('https://iptv-org.github.io/api/categories.json'));

      if (response.statusCode == 200) {
        List<CategoryModel> categories = (json.decode(response.body) as List)
            .map((item) => CategoryModel(name: item['name'], id: item['id']))
            .toList();
        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 6,
        backgroundColor: Colors.black,

        title: Text('Canada TV', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(

        children: [
          isLoadedTop
              ? SizedBox(
            height: bannerAdTop.size.height.toDouble(),
            width: bannerAdTop.size.width.toDouble(),
            child: bannerAdTop == null ? Container() : AdWidget(ad: bannerAdTop),
          )
              : SizedBox(),
          Container(
            height: size.height*0.75,
            child: FutureBuilder(
              future: Future.wait([fetchCategories(), fetchUSAChannels()]),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading data'));
                } else {
                  List<CategoryModel> categories = snapshot.data![0];
                  List<ChannelModel> usaChannels = snapshot.data![1];

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      CategoryModel category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChannelsList(
                                category: category,
                                channels: usaChannels,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          child: Center(
                            child: Text(category.name,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          // isLoadedBottom
          //     ? SizedBox(
          //   height: bannerAdBottom.size.height.toDouble(),
          //   width: bannerAdBottom.size.width.toDouble(),
          //   child: bannerAdBottom == null ? Container() : AdWidget(ad: bannerAdBottom),
          // )
          //     : SizedBox(),
        ],
      ),
      bottomSheet: isLoadedBottom
          ? SizedBox(
        height: bannerAdBottom.size.height.toDouble(),
        width: bannerAdBottom.size.width.toDouble(),
        child: bannerAdBottom == null ? Container() : AdWidget(ad: bannerAdBottom),
      )
          : SizedBox(),
    );
  }

}