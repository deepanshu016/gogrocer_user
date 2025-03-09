import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:user/models/about_us_model.dart';
import 'package:user/models/businessLayer/base_route.dart';
import 'package:user/models/terms_of_services_model.dart';

class AboutUsAndTermsOfServiceScreen extends BaseRoute {
  final bool isAboutUs;
  const AboutUsAndTermsOfServiceScreen(this.isAboutUs, {super.key, super.analytics, super.observer, super.routeName = 'AboutUsAndTermsOfServiceScreen'});
  @override
  BaseRouteState createState() => _AboutUsAndTermsOfServiceScreenState();
}

class _AboutUsAndTermsOfServiceScreenState extends BaseRouteState<AboutUsAndTermsOfServiceScreen> {
  bool _isDataLoaded = false;

  GlobalKey<ScaffoldState>? _scaffoldKey;
  String? text;
  AboutUs? _aboutUs = AboutUs();
  TermsOfService? _termsOfService = TermsOfService();

  _AboutUsAndTermsOfServiceScreenState();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.isAboutUs ? AppLocalizations.of(context)!.tle_about_us : AppLocalizations.of(context)!.tle_term_of_service,
          style: textTheme.titleLarge,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.keyboard_arrow_left)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _isDataLoaded
              ? Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  height: MediaQuery.of(context).size.height - 120,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Html(
                      data: "$text",
                      style: {
                        "body": Style(color: Theme.of(context).textTheme.bodyLarge!.color),
                      },
                    ),
                  ),
                )
              : _shimmerList(),
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    try {
      bool isConnected = await br.checkConnectivity();
      if (isConnected) {
        if (widget.isAboutUs) {
          await apiHelper.appAboutUs().then((result) async {
            if (result != null) {
              if (result.status == "1") {
                _aboutUs = result.data;
                text = _aboutUs!.description;
              }
            }
          });
        } else {
          await apiHelper.appTermsOfService().then((result) async {
            if (result != null) {
              if (result.status == "1") {
                _termsOfService = result.data;
                text = _termsOfService!.description;
              }
            }
          });
        }
      } else {
        showNetworkErrorSnackBar(_scaffoldKey);
      }
      _isDataLoaded = true;
      setState(() {});
    } catch (e) {
      debugPrint("Exception - aboutUsAndTermsOfServiceScreen.dart - _init():$e");
    }
  }

  Widget _shimmerList() {
    try {
      return ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(
              top: 8,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 112,
                    width: MediaQuery.of(context).size.width,
                    child: const Card(),
                  ),
                  const Divider(),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Exception - aboutUsAndTermsOfServiceScreen.dart - _shimmerList():$e");
      return const SizedBox();
    }
  }
}
