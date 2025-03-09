import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';

class DashboardBanner extends StatefulWidget {
  final List<Widget> items;
  final EdgeInsetsGeometry? margin;
  const DashboardBanner({super.key, this.margin, required this.items});

  @override
  State<DashboardBanner> createState() {
    return _DashboardBannerState();
  }
}

class _DashboardBannerState extends State<DashboardBanner> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  _DashboardBannerState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: widget.margin,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.15,
          child: CarouselSlider(
              items: widget.items,
              carouselController: _carouselController,
              options: CarouselOptions(
                  viewportFraction: 0.95,
                  initialPage: _currentIndex,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval:
                  const Duration(seconds: 3),
                  autoPlayAnimationDuration:
                  const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, _) {
                    _currentIndex = index;
                    setState(() {});
                  })
          ),
          // Text('${AppLocalizations.of(context).txt_nothing_to_show}'),
        ),
        Center(
          child: DotsIndicator(
            dotsCount: widget.items.length,
            position: _currentIndex,
            onTap: (i) {
              _currentIndex = i.toInt();
              _carouselController.animateToPage(
                  _currentIndex,
                  duration: const Duration(microseconds: 1),
                  curve: Curves.easeInOut);
            },
            decorator: DotsDecorator(
              activeSize: const Size(6, 6),
              size: const Size(6, 6),
              activeShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(50.0),
                ),
              ),
              activeColor: Theme.of(context).colorScheme.primary,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

}
