import 'package:cached_network_image/cached_network_image.dart';
import 'package:devconnect/core/colors.dart';
import 'package:devconnect/tabs/model/request.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Requestcontainer extends StatelessWidget {
  const Requestcontainer(
      {super.key,
      required this.request,
      required this.onaccept,
      required this.ondelete});
  final Request request;
  final Function(int id) onaccept;
  final Function(int id) ondelete;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        height: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueGrey)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: CachedNetworkImageProvider(
                        request.user!.profilePictureUrl!),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          request.user!.name!,
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                ondelete(request.id!);
                              },
                              child: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border:
                                      Border.all(color: Colors.red, width: 1.5),
                                ),
                                child: Center(
                                  child: Icon(Icons.close),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                onaccept(request.id!);
                              },
                              child: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border:
                                      Border.all(color: seedcolor, width: 1.5),
                                ),
                                child: Center(
                                  child: Icon(Icons.check),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text('Post Description'),
              ),
              Text(
                request.post!.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ),
    );
  }
}
