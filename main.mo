// importlar
import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

// canister -> akıllı sözlesmeler (actor)

actor Assistant {
  // class
  type ToDo = {
    description : Text;
    completed : Bool;
  };

  // fonksiyonlar -> update, query

  func natHash(n : Nat) : Hash.Hash {
    Text.hash(Nat.toText(n));
  };

  // degiskenler -> let = immutable, var = mutable

  var todos = Map.HashMap<Nat, ToDo>(0, Nat.equal, natHash);
  var nextId : Nat = 0;

  //async -> es zamanlı
  public query func getTodos() : async [ToDo] {
    Iter.toArray(todos.vals());
  };

  public func addTodo(description : Text) : async Nat {
    let id = nextId;
    todos.put(id, { description = description; completed = false });
    nextId += 1;
    id // or return id;
  };

  // loop -> for, if condition
  public query func showTodos() : async Text {
    var output : Text = "\n______TO-DOs______";
    for (todo : ToDo in todos.vals()) {
      output #= "\n" # todo.description;
      if (todo.completed) { output #= "tick" };
    };
    output # "\n";
  };

  // ignore, do
  public func completeTodo(id : Nat) : async () {
    ignore do ? {
      let description = todos.get(id)!.description;
      todos.put(id, { description; completed = true });
    };
  };

  public func clearCompleted() : async () {
    todos := Map.mapFilter<Nat, ToDo, ToDo>(
      todos,
      Nat.equal,
      natHash,
      func(_, todo) { if (todo.completed) null else ?todo },
    );
  };

};