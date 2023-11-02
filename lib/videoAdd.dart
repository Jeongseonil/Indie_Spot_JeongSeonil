// YouTube Data API를 통한 영상 검색 예시 (Dart)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class YoutubeAdd extends StatefulWidget {

  @override
  State<YoutubeAdd> createState() => _YoutubeTestState();
}

class _YoutubeTestState extends State<YoutubeAdd> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController videoUrl = TextEditingController();
  final TextEditingController videoTitle = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _search,
              focusNode: _focusNode,
              textInputAction: TextInputAction.go,
              onSubmitted: (value) {
                setState(() {

                });
              },
              decoration: InputDecoration(

                hintText: "등록할 영상을 검색하세요",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  onPressed: () {
                    _focusNode.unfocus();
                    _search.clear();
                    setState(() {

                    });
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black38))),
            child: FutureBuilder<List<Widget>>(
              future: searchYouTubeVideos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // 로딩 중 표시
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // 에러 발생 시 표시
                } else {
                  // 데이터가 있을 때 ListView.builder 반환
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return snapshot.data?[index]; // 반환된 ListTile 위젯 반환
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('영상 URL'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: videoUrl,
              textInputAction: TextInputAction.go,
              onSubmitted: (value) {
                String url = value;
                Uri uri = Uri.parse(url);
                String? videoId = uri.queryParameters['v'];
                setState(() {
                  _search.clear();
                  videoUrl.text = videoId!;
                });
              },

              decoration: InputDecoration(
                hintText: "등록할 영상의 URL을 입력하세요",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    _focusNode.unfocus();
                    videoUrl.clear();
                    videoTitle.clear();
                    setState(() {

                    });
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('영상 제목'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: videoTitle,
              decoration: InputDecoration(
                  hintText: "등록할 영상의 제목을 입력하세요",
                  border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    _focusNode.unfocus();
                    videoTitle.clear();
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget videoContent(){

      return Container(
        height: 200,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black38))),
        child: FutureBuilder<List<Widget>>(
          future: searchYouTubeVideos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // 로딩 중 표시
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // 에러 발생 시 표시
            } else {
              // 데이터가 있을 때 ListView.builder 반환
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return snapshot.data?[index]; // 반환된 ListTile 위젯 반환
                },
              );
            }
          },
        ),
      );
  }
  Future<List<Widget>> searchYouTubeVideos() async {
    final apiKey = 'AIzaSyBa_20_HToM18H1DKKDDqwlUshpBoNlPi8';
    final query = _search.text;
    final videoId = videoUrl.text;
    List<Widget> videoData = [];
    if(_search.text.isNotEmpty){
      final channelResponse = await http.get(Uri.parse(
          'https://www.googleapis.com/youtube/v3/search?key=$apiKey&q=$query&part=snippet&maxResults=1&type=channel'));
      videoTitle.text = "";
      if (channelResponse.statusCode == 200) {
        Map<String, dynamic> channelData = json.decode(channelResponse.body);
        String channelId = channelData['items'][0]['id']['channelId'];
        // 해당 채널의 영상 검색
        final response = await http.get(Uri.parse(
            'https://www.googleapis.com/youtube/v3/search?key=$apiKey&q=$query&part=snippet&maxResults=10&type=video'));

        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);
          List<dynamic> videos = data['items'];
          for (var video in videos) {
            videoData.add(
              ListTile(
                title: Text('${video['snippet']['title']}'),
                subtitle: Text('${video['snippet']['channelTitle']}'),
                leading: Image.network(
                    video['snippet']['thumbnails']['default']['url']),
                onTap: () {
                  videoUrl.text = video['id']['videoId'];
                  videoTitle.text = video['snippet']['title'];
                },
              ),
            );
          }
        } else {
          print('Failed to fetch videos. Error: ${response.reasonPhrase}');
        }
      }
    }else if(videoUrl.text.isNotEmpty){
      final response = await http.get(Uri.parse('https://www.googleapis.com/youtube/v3/videos?key=$apiKey&id=$videoId&part=snippet'));

      if (response.statusCode == 200) {
        Map<String, dynamic> videoData1 = json.decode(response.body);
        final snippet = videoData1['items'][0]['snippet'];
        final String title = snippet['title'];
        final String channelTitle = snippet['channelTitle'];
        final String thumbnailUrl = snippet['thumbnails']['default']['url'];
        videoTitle.text = title;
        videoData.add(
          ListTile(
            title: Text(title),
            subtitle: Text(channelTitle),
            leading: Image.network(thumbnailUrl),

          ),
        );

        // title, channelTitle, thumbnailUrl을 이용해 작업 수행
      } else {
        print('Failed to fetch video details. Error: ${response.reasonPhrase}');
      }
    }else{
      videoTitle.clear();
      videoData.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('등록할 영상을 검색하거나.'),
              Text('등록할 영상의 URL을 입력하세요.'),
            ],
          )
      );
    }
    return videoData;
  }
}