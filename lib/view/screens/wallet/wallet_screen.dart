import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/controller/wallet_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:sixam_mart/view/base/not_logged_in_screen.dart';
import 'package:sixam_mart/view/base/title_widget.dart';
import 'package:sixam_mart/view/screens/wallet/widget/history_item.dart';
import 'package:sixam_mart/view/screens/wallet/widget/wallet_bottom_sheet.dart';

import '../../../helper/route_helper.dart';
import '../../base/custom_button.dart';

class WalletScreen extends StatefulWidget {
  final bool fromWallet;
  const WalletScreen({Key? key, required this.fromWallet}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController scrollController = ScrollController();
  final bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();

  @override
  void initState() {
    super.initState();
    if(_isLoggedIn){
      Get.find<UserController>().getUserInfo();
      Get.find<WalletController>().getWalletTransactionList('1', false, widget.fromWallet);

      Get.find<WalletController>().setOffset(1);

      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent
            && Get.find<WalletController>().transactionList != null
            && !Get.find<WalletController>().isLoading) {
          int pageSize = (Get.find<WalletController>().popularPageSize! / 10).ceil();
          if (Get.find<WalletController>().offset < pageSize) {
            Get.find<WalletController>().setOffset(Get.find<WalletController>().offset + 1);
            if (kDebugMode) {
              print('end of the page');
            }
            Get.find<WalletController>().showBottomLoader();
            Get.find<WalletController>().getWalletTransactionList(Get.find<WalletController>().offset.toString(), false, widget.fromWallet);
          }
        }
      });
    }

  }
  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(title: widget.fromWallet ? 'wallet'.tr : 'loyalty_points'.tr, backButton: true),
      body: GetBuilder<UserController>(
          builder: (userController) {
            return _isLoggedIn ? userController.userInfoModel != null ? SafeArea(
              child: RefreshIndicator(
                onRefresh: () async{
                  Get.find<WalletController>().getWalletTransactionList('1', true, widget.fromWallet);
                  Get.find<UserController>().getUserInfo();
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0.0 : Dimensions.paddingSizeDefault),
                  child: FooterView(
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: GetBuilder<WalletController>(
                          builder: (walletController) {
                            return Column(children: [

                              Stack(
                                children: [
                                  Container(
                                    padding: widget.fromWallet ? const EdgeInsets.all(Dimensions.paddingSizeExtraLarge)
                                        : const EdgeInsets.only(top: 40, left: Dimensions.paddingSizeExtraLarge, right: Dimensions.paddingSizeExtraLarge),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      color: widget.fromWallet ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                    ),
                                    child:  Row(mainAxisAlignment: widget.fromWallet ? MainAxisAlignment.start : MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                      Image.asset( widget.fromWallet ? Images.wallet : Images.loyal , height: 60, width: 60, color: widget.fromWallet ? Theme.of(context).cardColor : null),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),

                                      widget.fromWallet ? Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('wallet_amount'.tr,style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor)),
                                            const SizedBox(height: Dimensions.paddingSizeSmall),

                                            Text(
                                              PriceConverter.convertPrice(userController.userInfoModel!.walletBalance), textDirection: TextDirection.ltr,
                                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor),
                                            ),
                                            SizedBox(height: 10,),
                                            GestureDetector(
                                              onTap: (){
                                                Get.offNamed(RouteHelper.getFundWalletRoute());
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(40),
                                                    color: Colors.white,
                                                  ),
                                                  height: 40,
                                                  child: Center(child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.add, color: Colors.green[900], size: 18,),
                                                        Text('fund_wallet'.tr + " ",style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.green[900])),
                                                      ],
                                                    ),
                                                  ))),
                                            )
                                          ]
                                      )
                                          : Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.end, children: [

                                            Text(
                                              userController.userInfoModel!.loyaltyPoint == null ? '0' : userController.userInfoModel!.loyaltyPoint.toString(),
                                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).textTheme.bodyLarge!.color),
                                            ),
                                            Text(
                                              '${'loyalty_points'.tr} !',
                                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                                            ),
                                            const SizedBox(height: Dimensions.paddingSizeSmall),
                                      ]),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),



                                    ]),
                                  ),

                                  widget.fromWallet ? const SizedBox.shrink() : Positioned(
                                    top: 10,right: 10,
                                    child: InkWell(
                                      onTap: (){
                                        ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                                            WalletBottomSheet(fromWallet: widget.fromWallet)
                                        ) : Get.dialog(
                                          Dialog(child: WalletBottomSheet(fromWallet: widget.fromWallet)),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            'convert_to_currency'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                                              color: widget.fromWallet ? Theme.of(context).cardColor : Theme.of(context).textTheme.bodyLarge!.color),
                                          ),
                                          Icon(Icons.keyboard_arrow_down_outlined,size: 16, color: widget.fromWallet ? Theme.of(context).cardColor
                                              : Theme.of(context).textTheme.bodyLarge!.color)
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ) ,


                              Column(children: [

                                Padding(
                                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
                                  child: TitleWidget(title: 'transaction_history'.tr),
                                ),
                                walletController.transactionList != null ? walletController.transactionList!.isNotEmpty ? GridView.builder(
                                  key: UniqueKey(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: 50,
                                    mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
                                    childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.45,
                                    crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                                  ),
                                  physics:  const NeverScrollableScrollPhysics(),
                                  shrinkWrap:  true,
                                  itemCount: walletController.transactionList!.length ,
                                  padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
                                  itemBuilder: (context, index) {
                                    return HistoryItem(index: index,fromWallet: widget.fromWallet, data: walletController.transactionList );
                                  },
                                ) : NoDataScreen(text: 'no_data_found'.tr) : WalletShimmer(walletController: walletController),

                                walletController.isLoading ? const Center(child: Padding(
                                  padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  child: CircularProgressIndicator(),
                                )) : const SizedBox(),
                              ])
                            ]);
                          }
                      ),
                    ),
                  ),
                ),
              ),
            ) : const Center(child: CircularProgressIndicator()) : const NotLoggedInScreen();
          }
      ),
    );
  }
}
class WalletShimmer extends StatelessWidget {
  final WalletController walletController;
  const WalletShimmer({Key? key, required this.walletController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.45,
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
      ),
      physics:  const NeverScrollableScrollPhysics(),
      shrinkWrap:  true,
      itemCount: 10,
      padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: walletController.transactionList == null,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                ],
              ),
              Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge), child: Divider(color: Theme.of(context).disabledColor)),
            ],
            ),
          ),
        );
      },
    );
  }
}