import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const GAME_ID = 'Gv3sMVfwTtQr66XaP9vr';

CollectionReference getGamesCollection() =>
    Firestore.instance.collection('Games');
DocumentReference getGameDocument({String gameId = GAME_ID}) =>
    Firestore.instance.collection('Games').document(gameId);
CollectionReference getCanvasItemsCollection({String gameId = GAME_ID}) =>
    Firestore.instance
        .collection('Games')
        .document(gameId)
        .collection('CanvasItems');
DocumentReference getCanvasItemDocument(
        {String gameId = GAME_ID, String canvasItemId}) =>
    Firestore.instance
        .collection('Games')
        .document(gameId)
        .collection('CanvasItems')
        .document(canvasItemId);

CollectionReference getVariablesCollection({String gameId = GAME_ID}) =>
    Firestore.instance
        .collection('Games')
        .document(gameId)
        .collection('Variables');

DocumentReference getVariableDocument(
        {String gameId = GAME_ID, @required String variableId}) =>
    Firestore.instance
        .collection('Games')
        .document(gameId)
        .collection('Variables')
        .document(variableId);
