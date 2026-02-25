import 'package:ecommerce_app/core/theme/app_colors.dart';
import 'package:ecommerce_app/features/onboarding/data/models/onboarding_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../app_start/presentation/bloc/app_start_cubit.dart';
import '../bloc/onboarding_cubit.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  final List<OnboardingModel> onboardingData = [
    OnboardingModel(
      title: 'Welcome to Our App',
      description: 'Explore our products and enjoy shopping',
      imagePath: 'assets/images/intro.png',
    ),
    OnboardingModel(
      title: 'Gợi ý theo độ tuổi',
      description: 'Chọn sản phẩm phù hợp với bé',
      imagePath: 'assets/images/intro1.png',
    ),
    OnboardingModel(
      title: 'Thanh toán an toàn',
      description: 'Nhanh chóng và tiện lợi',
      imagePath: 'assets/images/intro2.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              return Column(
                children: [
                  //pageview
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: onboardingData.length,
                      onPageChanged: (index) {
                        context.read<OnboardingCubit>().changePage(index);
                      },
                      itemBuilder: (context, index) {
                        final data = onboardingData[index];
                        return OnboardingPage(
                          title: data.title,
                          description: data.description,
                          imagePath: data.imagePath,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 60),

                  //indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.all(4),
                        width: state.pageIndex == index ? 14 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: state.pageIndex == index
                              ? Colors.blue
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  //const SizedBox(height: 20),

                  /// Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //nut bo qua
                        TextButton(
                          onPressed: () {
                            context.read<AppStartCubit>().completeOnboarding();
                          },
                          child: Text(
                            'Bỏ qua',
                            style: AppTextStyle.withColor(
                              AppTextStyle.buttonMedium,
                              Colors.grey[600]!,
                            ),
                          ),
                        ),
                        //nut tiep tuc
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            textStyle: AppTextStyle.buttonMedium,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (state.pageIndex == onboardingData.length - 1) {
                              context
                                  .read<AppStartCubit>()
                                  .completeOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            }
                          },
                          child: Text(
                            state.pageIndex == onboardingData.length - 1
                                ? "Bắt đầu"
                                : "Tiếp tục",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
