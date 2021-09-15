import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/home/home.dart';
import 'package:ecom/src/auth/google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:line_icons/line_icons.dart';
import 'package:email_validator/email_validator.dart';
import 'package:sweetsheet/sweetsheet.dart';

class Authentication extends HookWidget {
  final formKey = GlobalKey<FormState>();
  final SweetSheet _sweetSheet = SweetSheet();

  @override
  Widget build(BuildContext context) {
    final email = useState<String>("");
    final password = useState<String>("");
    final passwordVisible = useState<bool>(false);
    final signin = useState<bool>(true);
    final loading = useState<bool>(false);

    nextStep() {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => Home()),
        ModalRoute.withName("/"),
      );
    }

    onException(String text) {
      _sweetSheet.show(
        context: context,
        description: Text(text),
        color: SweetSheetColor.WARNING,
        positive: SweetSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          title: 'OK',
          icon: Icons.warning,
        ),
      );
    }

    Future<void> signIn() async {
      loading.value = true;
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.value,
          password: password.value,
        );
        nextStep();
      } on FirebaseAuthException catch (e) {
        loading.value = false;
        debugPrint(e.code);
        if (e.code == 'network-request-failed')
          onException("Vérifier votre connexion internet !");
        else if (e.code == 'weak-password')
          onException("Le mot de passe est trop faible !");
        else if (e.code == 'email-already-in-use')
          onException("Un autre compte existe déjà avec cette adresse mail !");
      } catch (e) {
        loading.value = false;
        debugPrint(e.toString());
      }
    }

    Future<void> signUp() async {
      loading.value = true;
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.value,
          password: password.value,
        );
        _sweetSheet.show(
          context: context,
          description: Text("Votre compte a été créé avec succès !"),
          color: SweetSheetColor.NICE,
          positive: SweetSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            title: 'Connectez-vous',
            icon: Icons.login,
          ),
        );
        loading.value = false;
        signin.value = true;
        if (userCredential.user != null)
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(
            {},
            SetOptions(merge: true),
          );
      } on FirebaseAuthException catch (e) {
        loading.value = false;
        debugPrint(e.code);
        if (e.code == 'network-request-failed')
          onException("Vérifier votre connexion internet !");
        else if (e.code == 'weak-password')
          onException("Le mot de passe est trop faible !");
        else if (e.code == 'email-already-in-use')
          onException("Un autre compte existe déjà avec cette adresse mail !");
      } catch (e) {
        loading.value = false;
        debugPrint(e.toString());
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .3,
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
                    vertical: 10,
                    horizontal: 10,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            signin.value ? "Se connecter" : "S'enregistrer",
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
                          onChanged: (value) {
                            email.value = value;
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez mettre votre adresse mail';
                            } else if (!EmailValidator.validate(value.trim())) {
                              return "L'adresse mail est invalide.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          obscureText: !passwordVisible.value,
                          onChanged: (value) {
                            password.value = value;
                          },
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez mettre votre mot de passe';
                            } else if (value.length < 7) {
                              return "le mot de passe doit avoir au moins 7 caractères";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        if (loading.value)
                          CircularProgressIndicator()
                        else
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
                                  vertical: 15,
                                )),
                              ),
                              onPressed: () {
                                if (formKey.currentState?.validate() == false)
                                  return;
                                if (signin.value)
                                  signIn();
                                else
                                  signUp();
                              },
                              child: Text(
                                signin.value ? "Se connecter" : "S'enregistrer",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 15),
                        if (signin.value)
                          Align(
                            alignment: Alignment.center,
                            child: Text.rich(
                              TextSpan(
                                text: "Vous n'avez pas de compte ? ",
                                children: [
                                  TextSpan(
                                    text: "Enregistez-vous",
                                    style: TextStyle(color: Colors.blueAccent),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        signin.value = false;
                                      },
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Align(
                            alignment: Alignment.center,
                            child: Text.rich(
                              TextSpan(
                                text: "Vous avez pas un compte ? ",
                                children: [
                                  TextSpan(
                                    text: "connectez-vous",
                                    style: TextStyle(color: Colors.blueAccent),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        signin.value = true;
                                      },
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
                        const SizedBox(height: 15),
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
                                    onSuccess: () => nextStep(),
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
