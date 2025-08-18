// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:speakup/common/widgets/appbar.dart';
// import 'package:speakup/features/speakup/controllers/speech_controller.dart';
// import 'package:speakup/features/speakup/screens/map_screen.dart';
// import 'package:speakup/util/constants/image_strings.dart';
// import 'package:speakup/util/constants/sizes.dart';
// import 'package:speakup/util/device/device_utility.dart';

// import '../../../util/constants/colors.dart';

// class HomeScreen1 extends StatelessWidget {
//   HomeScreen1({
//     super.key,
//   });
//   final SpeechController speechController = Get.find<SpeechController>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const SAppBar(
//         page: "Home",
//         title: "SpeakUP AI Чат",
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.arrow_forward),
//         onPressed: () {
//           Get.to(const MapScreen(text: ""));
//         },
//       ),
//       body: const SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(SSizes.defaultSpace),
//           child: SizedBox(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [],
//             ),
//           ),
//         ),
//       ),
//       bottomSheet: Container(
//         padding: const EdgeInsets.all(SSizes.spaceBtwSections * 2),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//               topRight: Radius.circular(30), topLeft: Radius.circular(30)),
//         ),
//         height: SDeviceUtils.getScreenHeight(context) * .4,
//         width: SDeviceUtils.getScreenWidth(context),
//         child: Column(
//           children: [
//             Obx(() {
//               return Text(
//                 speechController.isListening ? "Слушаю... " : "",
//                 style: Theme.of(context).textTheme.titleLarge,
//               );
//             }),
//             const SizedBox(height: SSizes.spaceBtwSections),
//             IconButton(
//               icon: const Icon(
//                 Icons.mic,
//                 color: Colors.white,
//               ),
//               iconSize: 100,
//               onPressed: () {
//                 speechController.listen(false);
//               },
//               style: IconButton.styleFrom(
//                 backgroundColor: SColors.primary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
