import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/category_list_model.dart';
import 'package:user/models/subcategory_model.dart';

class SelectCategoryCard extends StatefulWidget {
  final CategoryList? category;

  final Function() onPressed;
  final bool? isSelected;
  final double? borderRadius;
  final SubCategory? subCategory;
  final int? screenId;
  const SelectCategoryCard({super.key, this.category, required this.isSelected, required this.onPressed, this.borderRadius, this.subCategory, this.screenId});

  @override
  State<SelectCategoryCard> createState() => _SelectCategoryCardState();
}

class _SelectCategoryCardState extends State<SelectCategoryCard> {

  _SelectCategoryCardState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Card(
        margin: const EdgeInsets.only(top: 3, bottom: 3, right: 16),
        child: InkWell(
          onTap: widget.onPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  alignment: Alignment.center,
                  child: CachedNetworkImage(
                    imageUrl: widget.screenId == 1 ? global.appInfo!.imageUrl! + widget.subCategory!.image! : global.appInfo!.imageUrl! + widget.category!.image!,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundColor: widget.isSelected! ? Colors.white : const Color(0xffFFF5F4),
                      radius: 35,
                      backgroundImage: imageProvider,
                    ),

                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => CircleAvatar(
                      backgroundColor: widget.isSelected! ? Colors.white : const Color(0xffFFF5F4),
                      radius: 30,
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  height: 42,
                  alignment: Alignment.center,
                  child: Text(
                    widget.screenId == 1 ? widget.subCategory!.title! : widget.category!.title!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      // color: !isSelected! ? Theme.of(context).primaryTextTheme.labelSmall?.color : Theme.of(context).textSelectionTheme.selectionColor,
                      fontWeight: widget.isSelected! ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

class SelectCategoryCard1 extends StatefulWidget {
  final CategoryList? category;

  final Function onPressed;
  final bool isSelected;
  final double? borderRadius;
  final SubCategory? subCategory;
  final int? screenId;

  const SelectCategoryCard1({super.key, this.category, required this.isSelected, required this.onPressed, this.borderRadius, this.subCategory, this.screenId});

  @override
  State<SelectCategoryCard1> createState() => _SelectCategoryCardState1();
}

class _SelectCategoryCardState1 extends State<SelectCategoryCard1> {

  _SelectCategoryCardState1();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 3, bottom: 3,right: 16),
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius == null ? BorderRadius.circular(5) : BorderRadius.circular(5),
        color: widget.isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
        boxShadow: [
          BoxShadow(
            color: widget.isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
            blurRadius: 4,
            offset: const Offset(0, 0.75),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          shadowColor: Theme.of(context).colorScheme.primary,
          elevation: widget.isSelected ? 5 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: widget.borderRadius == null ? BorderRadius.circular(5) : BorderRadius.circular(5),
          ),
          fixedSize: const Size.fromWidth(93),
        ),
        onPressed: () {
          widget.onPressed();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 62,
                child: CachedNetworkImage(
                  imageUrl: widget.screenId == 1 ? global.appInfo!.imageUrl! + widget.subCategory!.image! : global.appInfo!.imageUrl! + widget.category!.image!,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    backgroundColor: widget.isSelected ? Colors.white : const Color(0xffFFF5F4),
                    radius: 35,
                    backgroundImage: imageProvider,
                  ),

                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => CircleAvatar(
                    backgroundColor: widget.isSelected ? Colors.white : const Color(0xffFFF5F4),
                    radius: 30,
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                height: 42,
                alignment: Alignment.center,
                child: Text(
                  widget.screenId == 1 ? widget.subCategory!.title! : widget.category!.title!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: !widget.isSelected ? Colors.black : Colors.white,
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
