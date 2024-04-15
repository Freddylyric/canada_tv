import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:canada_iptv/adapters/category_model.dart';
import 'package:canada_iptv/video_player_screen.dart';
import 'adapters/channels_model.dart';
// Assuming you have a Channels model

import 'package:flutter/material.dart';

class ChannelsList extends StatefulWidget {
  final List<ChannelModel> channels;
  final CategoryModel category;

  const ChannelsList({Key? key, required this.channels, required this.category}) : super(key: key);

  @override
  _ChannelsListState createState() => _ChannelsListState();
}

class _ChannelsListState extends State<ChannelsList> {
  late List<ChannelModel> filteredChannels;
  late BannerAd bannerAdTop;
  late BannerAd bannerAdBottom;
  bool isLoadedTop = false;
  bool isLoadedBottom = false;
  var adUnitTop =
      "ca-app-pub-9354755118881714/4794770254"; // Change this to your top ad unit ID
  var adUnitBottom =
      "ca-app-pub-9354755118881714/7065710378"; // Change this to your bottom ad unit ID
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filterChannels();
    initBannerAds();
  }

  void filterChannels() {
    setState(() {
      filteredChannels = widget.channels.where((channel) =>
      channel.categories != null &&
          channel.categories!.isNotEmpty &&
          channel.categories!.contains(widget.category.id.toLowerCase()) &&
          channel.name.toLowerCase().contains(searchController.text.toLowerCase())
      ).toList();
    });
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 6,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(widget.category.name, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  filterChannels();
                },
                decoration: InputDecoration(
                  hintText: 'Search channels...',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        filterChannels();
                      });
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          isLoadedTop
              ? SizedBox(
            height: bannerAdTop.size.height.toDouble(),
            width: bannerAdTop.size.width.toDouble(),
            child: bannerAdTop == null ? Container() : AdWidget(ad: bannerAdTop),
          )
              : SizedBox(),
          Container(
            height: size.height * 0.68,
            child: filteredChannels.isEmpty
                ? Center(
              child: Text(
                'Channels are currently unavailable. Please check back later.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: filteredChannels.length,
              itemBuilder: (context, index) {
                ChannelModel channel = filteredChannels[index];
                return Card(
                  child: ListTile(
                    leading: _buildLogoWidget(channel.logo),
                    title: Text(channel.name),
                    subtitle: Text(channel.id),
                    onTap: () async {
                      String streamingLink = channel.streamingLink;
                      if (streamingLink.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              url: streamingLink,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
          isLoadedBottom
              ? SizedBox(
            height: bannerAdBottom.size.height.toDouble(),
            width: bannerAdBottom.size.width.toDouble(),
            child: bannerAdBottom == null ? Container() : AdWidget(ad: bannerAdBottom),
          )
              : SizedBox(),
        ]),
      ),
    );
  }

  Widget _buildLogoWidget(String logoUrl) {
    if (logoUrl.isEmpty) {
      return CircularProgressIndicator();
    } else {
      return Container(
        width: 50,
        height: 50,
        child: Image.network(
          logoUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container();
          },
        ),
      );
    }
  }
}