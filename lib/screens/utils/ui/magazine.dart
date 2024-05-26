
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class FoodMagazines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(2.w),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Padding(
        padding:  EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Food Magazines',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                color: Colors.amber.shade900,
              ),
            ),
            SizedBox(height: 2.h),
            FoodMagazineItem(
              magazineName1: 'Food & Wine',
              imageUrl1: 'assets/food.png',
              magazineUrl1: 'https://www.foodandwine.com/',
              magazineName2: 'Bon Appétit',
              imageUrl2: 'assets/bon.png',
              magazineUrl2: 'https://www.bonappetit.com/',
              magazineName3: 'Saveur',
              imageUrl3: 'assets/saveur.png',
              magazineUrl3: 'https://www.saveur.com/',
            ),
          ],
        ),
      ),
    );
  }
}
class FoodMagazineItem extends StatelessWidget {
  final String magazineName1;
  final String imageUrl1;
  final String magazineUrl1;
  final String magazineName2;
  final String imageUrl2;
  final String magazineUrl2;
  final String magazineName3;
  final String imageUrl3;
  final String magazineUrl3;

  const FoodMagazineItem({
    required this.magazineName1,
    required this.imageUrl1,
    required this.magazineUrl1,
    required this.magazineName2,
    required this.imageUrl2,
    required this.magazineUrl2,
    required this.magazineName3,
    required this.imageUrl3,
    required this.magazineUrl3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildMagazineItem(
          magazineName1,
          imageUrl1,
          magazineUrl1,
        ),
        SizedBox(width: 2.w),
        _buildMagazineItem(
          magazineName2,
          imageUrl2,
          magazineUrl2,
        ),
        SizedBox(width: 2.w),
        _buildMagazineItem(
          magazineName3,
          imageUrl3,
          magazineUrl3,
        ),
      ],
    );
  }

  Widget _buildMagazineItem(
      String magazineName,
      String imageUrl,
      String magazineUrl,
      ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _launchURL(magazineUrl);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.w),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.w),
            child: Stack(
              children: [
                Image.asset(
                  imageUrl,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: 17.h, // Adjust the height as needed
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 1.h,
                  left: 1.w,
                  right: 1.w,
                  child: Text(
                    magazineName,
                    style: TextStyle(
                      color:  Colors.amber.shade900,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (url.isNotEmpty) {
      try {
        await launch(url);
      } catch (e) {
        print('Error launching URL: $e');
      }
    } else {
      print('URL is null or empty');
    }
  }


}
