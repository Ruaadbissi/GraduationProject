import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:magic_cook1/screens/register/register.dart';
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
  void initState() {
    super.initState();
    // Start slideshow
    _startSlideshow();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startSlideshow() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentPage < _slides.length - 1) {
        _currentPage++;
      } else {
        timer.cancel(); // Stop the timer
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                    return Container(
                      width: 100.w,
                      height: 100.h,
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
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 20.h,
                  child: Container(
                    width: 100.w,
                    child: Text(
                      _slides[_currentPage]['text']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.sp,
                        fontFamily: "Raleway-Bold",
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2.h,
                  right: 10.w,
                  left: 10.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                          (index) => Container(
                        margin: EdgeInsets.only(right: 1.w),
                        width: 7.w,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4.h,
                  right: 2.w,
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
                        fontSize: 2.5.h,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10.h,
                  left: 2.h,
                  right: 2.h,
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
                              MaterialPageRoute(builder: (context) => navigationBar()),
                            );
                          }
                        },
                        child: Text(
                          _currentPage == _slides.length - 1 ? 'Start your journey now!' : 'Next',
                          style: TextStyle(
                            fontSize: 3.h,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.amber.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.w),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
