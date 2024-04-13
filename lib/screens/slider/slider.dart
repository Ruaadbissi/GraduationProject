import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/register/register.dart';
import 'package:magic_cook1/screens/register/registerTest.dart';
import 'package:magic_cook1/screens/utils/ui/navigation/navigationBar.dart';

class sliderScreen extends StatefulWidget {
  @override
  _sliderScreenState createState() => _sliderScreenState();
}

class _sliderScreenState extends State<sliderScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  List<Map<String, String>> _slides = [
    {
      'image': 'assets/preview1.jpeg',
      'text': 'Get Ready to Taste the best Flavours',
    },
    {
      'image': 'assets/preview2.jpg',
      'text': 'Creating this app for your Own Flavory pleasure',
    },
    {
      'image': 'assets/preview3.jpg',
      'text': 'Every ingredient is Magic for your little Chef inside',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_slides[_currentPage]['image']!),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(1),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container();
                    },
                  ),
                  Positioned(
                    bottom: 150,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        _slides[_currentPage]['text']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontFamily: "Raleway-Bold",
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 10,
                    left: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                            (index) => Container(
                          margin: EdgeInsets.only(right: 5),
                          width: 40,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: TextButton(
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.jumpToPage(_slides.length - 1);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => register()),
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _slides.length - 1 ? 'Register' : 'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _slides.length - 1) {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  navigationBar()),
                              );
                            }
                          },
                          child: Text(
                            _currentPage == _slides.length - 1 ? 'Start your journey now!' : 'Next',
                            style: TextStyle(
                              fontSize: 22,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary:Colors.amber.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
