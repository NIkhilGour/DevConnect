import 'package:devconnect/core/jwtservice.dart';
import 'package:devconnect/error_screen.dart';
import 'package:devconnect/tabs/apiServices/requestnotifier.dart';
import 'package:devconnect/tabs/widgets/requestcontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Postrequestscreen extends ConsumerStatefulWidget {
  const Postrequestscreen({super.key});

  @override
  ConsumerState<Postrequestscreen> createState() => _PostrequestscreenState();
}

class _PostrequestscreenState extends ConsumerState<Postrequestscreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 800;
    final requestdata = ref.watch(requestProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(isMobile ? Icons.arrow_back : Icons.close),
        ),
        title: Text(
          'Collaboration Request',
          style: GoogleFonts.lato(
            fontSize: isMobile ? 18.sp : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: requestdata.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(child: Text('No Request Available'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Requestcontainer(
                onaccept: (id) async {
                  try {
                    await ref
                        .watch(requestProvider.notifier)
                        .toggleAcceptRequest(id);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Request can not accepted')),
                      );
                    }
                  }
                },
                ondelete: (id) async {
                  try {
                    await ref
                        .watch(requestProvider.notifier)
                        .toggleDeleteRequest(id);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Request can not deleted')),
                      );
                    }
                  }
                },
                request: data[index],
              );
            },
          );
        },
        error: (error, stackTrace) {
          return ErrorScreen(
            message: 'Something Went Wrong',
            onRetry: () async {
              final token = await JWTService.gettoken();
              if (context.mounted) {
                await JWTService.validateTokenAndRedirect(context, token!);
              }

              ref.refresh(requestProvider);
            },
          );
        },
        loading: () {
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
