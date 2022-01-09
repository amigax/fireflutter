import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/defines.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';

class PhoneNumberInput extends StatefulWidget {
  PhoneNumberInput({
    this.favorites = const ['US', 'KR'],
    this.onChanged,
    required this.countryButtonBuilder,
    required this.countrySelectedBuilder,
    required this.codeSent,
    required this.error,
    required this.success,
    required this.codeAutoRetrievalTimeout,
    this.inputTitle = const SizedBox.shrink(),
    this.dialCodeStyle = const TextStyle(fontSize: 24),
    this.phoneNumberInputDecoration = const InputDecoration(),
    this.phoneNumberInputTextStyle = const TextStyle(),
    this.submitTitle = const SizedBox.shrink(),
    this.submitButton = const Text(
      'Submit',
      style: TextStyle(color: Colors.blue, fontSize: 24),
    ),
    Key? key,
  }) : super(key: key);

  final List<String> favorites;
  final void Function(CountryCode)? onChanged;
  final Widget Function() countryButtonBuilder;
  final Widget Function(CountryCode) countrySelectedBuilder;
  final void Function(String verificationId) codeSent;
  final VoidCallback success;
  final ErrorCallback error;
  final void Function(String) codeAutoRetrievalTimeout;
  final TextStyle dialCodeStyle;
  final InputDecoration phoneNumberInputDecoration;
  final TextStyle phoneNumberInputTextStyle;
  final Widget submitButton;
  final Widget inputTitle;
  final Widget submitTitle;

  @override
  _PhoneNumberInputState createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  @override
  void initState() {
    super.initState();

    PhoneService.instance.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CountryCodePicker(
          onChanged: (CountryCode code) {
            PhoneService.instance.selectedCode = code;
            if (widget.onChanged != null) widget.onChanged!(code);
            setState(() {});
          },
          favorite: widget.favorites,
          comparator: (a, b) {
            /// sort by country dial code
            int re = b.dialCode!.compareTo(a.dialCode!);
            return re == 0 ? 0 : (re < 0 ? 1 : -1);
          },
          builder: (CountryCode? code) {
            return PhoneService.instance.selectedCode == null
                ? widget.countryButtonBuilder()
                : widget.countrySelectedBuilder(code!);
          },
        ),
        if (PhoneService.instance.selectedCode != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.inputTitle,
              Row(
                children: [
                  Text(
                    PhoneService.instance.selectedCode!.dialCode!,
                    style: widget.dialCodeStyle,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: widget.phoneNumberInputTextStyle,
                      decoration: widget.phoneNumberInputDecoration,
                      keyboardType: TextInputType.phone,
                      onChanged: (t) {
                        PhoneService.instance.domesticPhoneNumber = t;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        if (PhoneService.instance.domesticPhoneNumber != '' &&
            PhoneService.instance.codeSentProgress == false)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.submitTitle,
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    PhoneService.instance.codeSentProgress = true;
                  });
                  PhoneService.instance.phoneNumber = PhoneService.instance.completeNumber;
                  PhoneService.instance.verifyPhoneNumber(
                    codeSent: widget.codeSent,
                    success: widget.success,
                    error: widget.error,
                    codeAutoRetrievalTimeout: widget.codeAutoRetrievalTimeout,
                  );
                },
                child: widget.submitButton,
              ),
            ],
          ),
        if (PhoneService.instance.codeSentProgress) CircularProgressIndicator.adaptive(),
      ],
    );
  }
}
