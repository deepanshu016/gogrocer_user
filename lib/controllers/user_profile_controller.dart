import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:user/models/address_model.dart';
import 'package:user/models/businessLayer/api_helper.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/user_model.dart';

class UserProfileController extends GetxController {
  APIHelper apiHelper = APIHelper();
  CurrentUser? currentUser;
  List<Address> addressList = [];
  var isDataLoaded = false.obs;
  var isAddressDataLoaded = false.obs;
 

  getMyProfile() async {
    try {
      if (global.currentUser?.id != null) {
        dynamic result = await apiHelper.myProfile();
        if (result != null) {
          if (result.status == "1") {
            currentUser = result.data;
            global.currentUser = currentUser;
          }
        }
        isDataLoaded.value = true;
        update();
      }
    } catch (e) {
      debugPrint("Exception - user_profile_controller.dart - _getMyProfile():$e");
    }
  }

  getUserAddressList() async {
    try {
      dynamic result = await apiHelper.getAddressList();
      if (result != null) {
        if (result.status == "1") {
          addressList = result.data;
          global.addressList.addAll(global.addressList);
        }
      }
      isAddressDataLoaded.value = true;
      update();
    } catch (e) {
      debugPrint("Exception - user_profile_controller.dart - _init():$e");
    }
  }

  removeUserAddress(int index) async {
    try {
      await apiHelper.removeAddress(addressList[index].addressId).then((result) async {
        if (result != null) {
          if (result.status == "1") {
            addressList.removeAt(index);
          }
        }
      });
      update();
    } catch (e) {
      debugPrint("Exception - user_profile_controller.dart - _removeAddress():$e");
    }
  }
}
