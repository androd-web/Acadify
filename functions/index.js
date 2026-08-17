const functions = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

exports.createUser = functions.onCall(async (request) => {
  // 1. Vérifier que l'appelant est authentifié
  if (!request.auth) {
    throw new functions.HttpsError(
        "unauthenticated",
        "Vous devez être connecté pour effectuer cette action.",
    );
  }

  // 2. Vérifier que l'appelant est bien admin
  const callerDoc = await admin
      .firestore()
      .collection("users")
      .doc(request.auth.uid)
      .get();

  if (!callerDoc.exists || callerDoc.data().role !== "admin") {
    throw new functions.HttpsError(
        "permission-denied",
        "Seul un administrateur peut créer un utilisateur.",
    );
  }

  // eslint-disable-next-line max-len
  const {email, password, name, role, matricule, filiere, niveau, specialite, poste} =
    request.data;

  if (!email || !password || !name || !role) {
    throw new functions.HttpsError(
        "invalid-argument",
        "Champs obligatoires manquants (email, password, name, role).",
    );
  }

  let userRecord;

  try {
    // 3. Créer le compte Firebase Auth
    userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: name,
    });
  } catch (error) {
    // eslint-disable-next-line max-len
    throw new functions.HttpsError("internal", "Erreur Auth : " + error.message);
  }

  try {
    // 4. Créer le document Firestore avec le MÊME uid que Auth
    const userData = {
      name: name,
      email: email,
      role: role, // "student" | "teacher" | "admin"
      forcePasswordChange: true,
      status: "active",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (role === "student") {
      userData.matricule = matricule;
      userData.filiere = filiere;
      userData.niveau = niveau;
    } else if (role === "teacher") {
      userData.specialite = specialite;
    } else if (role === "admin") {
      userData.poste = poste;
    }

    // eslint-disable-next-line max-len
    await admin.firestore().collection("users").doc(userRecord.uid).set(userData);

    return {success: true, uid: userRecord.uid};
  } catch (error) {
    // Si Firestore échoue après création du compte Auth, on supprime
    // le compte Auth orphelin pour éviter un état incohérent.
    await admin.auth().deleteUser(userRecord.uid);
    // eslint-disable-next-line max-len
    throw new functions.HttpsError("internal", "Erreur Firestore : " + error.message);
  }
});
