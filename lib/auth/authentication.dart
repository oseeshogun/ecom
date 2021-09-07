import 'package:ecom/home/home.dart';
import 'package:ecom/src/auth/google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:line_icons/line_icons.dart';

class Authentication extends HookWidget {
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final email = useState<String>("");
    final password = useState<String>("");
    final passwordVisible = useState<bool>(false);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .35,
                child: Container(
                  color: Color(0xFFF5F5F5),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/svgs/undraw_Access_account_re_8spm.svg",
                      height: MediaQuery.of(context).size.height * .2,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Se connecter",
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: "Votre adresse mail",
                            labelText: "Email",
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          obscureText: !passwordVisible.value,
                          decoration: InputDecoration(
                            hintText: "Mot de passe",
                            labelText: "Mot de passe",
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            suffixIcon: IconButton(
                              icon: Visibility(
                                visible: !passwordVisible.value,
                                replacement: Icon(Icons.visibility_off),
                                child: Icon(Icons.visibility),
                              ),
                              onPressed: () {
                                passwordVisible.value = !passwordVisible.value;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .8,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.symmetric(
                                vertical: 20,
                              )),
                            ),
                            onPressed: () {},
                            child: Text(
                              "Se connecter",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          child: Text.rich(
                            TextSpan(
                              text: "Vous n'avez pas de compte ? ",
                              children: [
                                TextSpan(
                                  text: "Enregistez-vous",
                                  style: TextStyle(color: Colors.blueAccent),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(height: 3, color: Colors.black)),
                            Text(" ou connectez-vous avec "),
                            Expanded(
                                child: Divider(height: 3, color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              shape: CircleBorder(),
                              elevation: 5,
                              child: IconButton(
                                icon: Icon(LineIcons.googleLogo),
                                onPressed: () {
                                  loginWithGmail(
                                    onSuccess: () {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (_) => Home()),
                                        ModalRoute.withName("/"),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
