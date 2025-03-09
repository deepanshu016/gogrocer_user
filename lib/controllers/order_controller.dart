import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:user/models/businessLayer/api_helper.dart';
import 'package:user/models/order_model.dart';

class OrderController extends GetxController {
  APIHelper apiHelper = APIHelper();
  List<Order> completedOrderList = [];
  List<Order>? activeOrderList = [];
  var isCompletedOrderHistoryListLoaded = false.obs;
  var isActiveOrderListLoaded = false.obs;
  var isDataLoaded2 = false.obs;
  var isDeleted = false.obs;

  var page = 1.obs;

  var isMoreDataLoaded = false.obs;
  var isRecordPending = true.obs;

  var page1 = 1.obs;
 
  var isMoreDataLoaded1 = false.obs;
  var isRecordPending1 = true.obs;

  deleteOrder(String? cartId, String? cancelReason) async {
    try {
      isDataLoaded2.value = false;
      final result = await apiHelper.deleteOrder(cartId, cancelReason);

      if (result != null) {
        if (result.status == "1") {
          isDeleted.value = true;
          Get.snackbar(
            "Order Cancelled.",
            "",
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          isDeleted.value = false;
          Get.snackbar(
            "Order Cancellation Failed.",
            "",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }

      isDataLoaded2.value = true;
      update();
    } catch (e) {
      debugPrint("Exception -  order_controller.dart - deleteOrder():$e");
    }
  }

  getActiveOrderList() async {
    try {
      isActiveOrderListLoaded.value = false;

      if (isRecordPending1.value == true) {
        isMoreDataLoaded1.value = true;

        if (activeOrderList!.isEmpty) {
          page1.value = 1;
        } else {
          page1.value++;
        }

        final result = await apiHelper.getActiveOrders(page1.value);
        if (result != null) {
          if (result.status == "1") {
            List<Order> tList = result.data;
            if (tList.isEmpty) {
              isRecordPending1.value = false;
            }
            activeOrderList!.addAll(tList);

            isMoreDataLoaded1.value = false;
          } else {
            activeOrderList = null;
          }
        }
      }

      isActiveOrderListLoaded.value = true;
      update();
    } catch (e) {
      debugPrint("Exception -  order_controller.dart - getActiveOrderList():$e");
    }
  }

  getCompletedOrderHistoryList() async {
    try {
      isCompletedOrderHistoryListLoaded.value = false;

      if (isRecordPending.value == true) {
        isMoreDataLoaded.value = true;

        if (completedOrderList.isEmpty) {
          page.value = 1;
        } else {
          page.value++;
        }

        final result = await apiHelper.getCompletedOrders(page.value);
        if (result != null) {
          if (result.status == "1") {
            List<Order> tList = result.data;
            if (tList.isEmpty) {
              isRecordPending.value = false;
            }
            completedOrderList.addAll(tList);

            isMoreDataLoaded.value = false;
          } else {
            completedOrderList = [];
          }
        }
      }

      isCompletedOrderHistoryListLoaded.value = true;
      update();
    } catch (e) {
      debugPrint("Exception -  order_controller.dart - getOrderHistoryList():$e");
    }
  }

  getOrderHistory() async {
    debugPrint("Fetching order history");
    final List<dynamic> _ = await Future.wait([
      getActiveOrderList(),
      getCompletedOrderHistoryList()
    ]);
  }
}
