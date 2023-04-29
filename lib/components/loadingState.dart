import 'package:finalmicrophone/components/resusableGesture.dart';
import 'package:flutter/material.dart';


class LoadingState extends StatelessWidget {
  final Function()? onTap;
  LoadingState({ required this.onTap});

  @override
  Widget build(BuildContext context) {
 return Container(
   child: Column(
     mainAxisAlignment: MainAxisAlignment.start,
     children: [
       SizedBox(height: 30,),
       Padding(
         padding: const EdgeInsets.symmetric(horizontal: 10),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Expanded(
               child: Container(),
             ),
             CustomButton(
               text: 'Cancel and Go back',
               onTap: onTap
             ),
           ],
         ),
       ),
       SizedBox(height: 200),
       Center(child: CircularProgressIndicator()),
     ],
   ),
 );

  }
}