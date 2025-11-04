import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ai_support/sm_ai_support.dart';
import 'package:sm_ai_support/src/core/global/components/custom_text_field/custom_text_field.dart';
import 'package:sm_ai_support/src/core/global/components/custom_text_field/phone/phone_text_field.dart';
import 'package:sm_ai_support/src/core/global/design_system.dart';
import 'package:sm_ai_support/src/core/utils/extension/size_extension.dart';
import 'package:sm_ai_support/src/core/utils/utils.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_cubit.dart';
import 'package:sm_ai_support/src/features/auth/cubit/auth_state.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UserModel registrationBody = const UserModel();

  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  // Create persistent controllers
  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    nameController = TextEditingController(text: registrationBody.fullName);
    phoneController = TextEditingController(text: registrationBody.phoneNumber);

    // Get the cubit from context after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCubit = context.read<AuthCubit>();
      if (authCubit.state.registrationBody != null) {
        setState(() {
          registrationBody = authCubit.state.registrationBody!;
          nameController.text = registrationBody.fullName;
          phoneController.text = registrationBody.phoneNumber;
        });
        validate();
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RegisterForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    validate();
  }

  void validate() {
    final bool allFieldsFilled =
        registrationBody.fullName.isNotEmpty &&
        registrationBody.countryCode.isNotEmpty &&
        registrationBody.phoneNumber.isNotEmpty;
    isButtonEnabled.value = allFieldsFilled;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: nameController,
            topTitleText: SMText.fullName,
            keyboardType: TextInputType.name,
            hintText:
                '${SMText.example} : '
                '"عبدالله"',
            validator: (value) => Utils.nameValidator(value),
            onChanged: (value) {
              registrationBody = registrationBody.copyWith(fullName: value);
              validate();
            },
          ),
          SizedBox(height: 20.rh),
          PhoneTextField(
            initCountryCode: registrationBody.countryCode.isEmpty ? null : registrationBody.countryCode,
            controller: phoneController,
            onCountryChanged: (country) {
              registrationBody = registrationBody.copyWith(countryCode: country.dialCode);
              validate();
            },
            onChanged: (value) {
              registrationBody = registrationBody.copyWith(phoneNumber: value);
              validate();
            },
          ),
          SizedBox(height: 70.rh),
          ValueListenableBuilder<bool>(
            valueListenable: isButtonEnabled,
            builder: (context, value, child) => BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return DesignSystem.primaryButton(
                  title: SMText.followUp,
                  height: 52.rh,
                  isDisabled: !value || state.registerStatus.isLoading,
                  showLoading: state.registerStatus.isLoading,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final authCubit = context.read<AuthCubit>();

                    // Update authCubit with registration body
                    authCubit.updateRegistrationBody(registrationBody);

                    // Call register method
                    await authCubit.register();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
