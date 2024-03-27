import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/not_logged_in_screen.dart';

import '../../../helper/route_helper.dart';
import '../../base/custom_text_field.dart';

class FundWalletScreen extends StatefulWidget {
  const FundWalletScreen({Key? key}) : super(key: key);

  @override
  State<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends State<FundWalletScreen> {
  late bool _isLoggedIn;
  final FocusNode _amountFocus = FocusNode();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();

    if(_isLoggedIn && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
  }

  String generateRandomNumberString(int length) {
    final random = Random();
    String numberString = '';

    for (int i = 0; i < length; i++) {
      numberString += random.nextInt(10).toString();
    }

    return numberString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(title: 'fund_wallet'.tr),
      body: Center(
        child: _isLoggedIn ? SingleChildScrollView(
          child: FooterView(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: GetBuilder<UserController>(builder: (userController) {
                  return Column( children: [
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Text('add_to_wallet'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(
                      '${'pay_easily_from_wallet'.tr}',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault), textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 40),

                    Center(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Column(children: [
                          Image.asset(Images.earnMoney, width: ResponsiveHelper.isDesktop(context) ? 200 : 100,
                              height: ResponsiveHelper.isDesktop(context) ? 250 : 150, fit: BoxFit.contain),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Text('enter_amount'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeDefault)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),


                      CustomTextField(
                        hintText: 'amount'.tr,
                        controller: _amountController,
                        focusNode: _amountFocus,
                        inputType: TextInputType.number,
                        inputAction: TextInputAction.done,
                        prefixIcon: Images.wallet,
                        divider: true,
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    CustomButton(buttonText: 'fund_wallet'.tr,icon: Icons.wallet, onPressed: (){
                      String amount = _amountController.text.trim();
                      if(amount.isEmpty){
                        showCustomSnackBar('enter_amount'.tr);
                      } else {
                        Get.offNamed(RouteHelper.getFundingRoute(
                            generateRandomNumberString(8), Get.find<UserController>().userInfoModel!.id, 'funding', double.parse(amount)
                        ));
                      }
                    }),

                  ]);
                }
                ),
              ),
            ),
          ),
        ) : const NotLoggedInScreen(),
      ),
    );
  }
}
