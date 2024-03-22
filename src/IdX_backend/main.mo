import List "mo:base/List";
import Nat32 "mo:base/Nat32";
import Blob "mo:base/Blob";
import Random "mo:base/Random";
import TrieMap "mo:base/TrieMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
actor {

  type UserAddress = {
    state : Text;
    street : Text;
    city : Text;
  };

  type UserDOB = {
    month : Nat;
    day : Nat;
    year : Nat;
  };

  type UserData = {
    name : Text;
    address1 : UserAddress;
    address2 : UserAddress;
    dob : UserDOB;
    nin : Nat;
    age : Nat;
    state_of_origin : Text;
  };

  type AccessKey = {
    key : Text;
    allowedPrivileges : List.List<Domain>;
    allowedData : List.List<Text>;
  };

  type Domain = {
    #Url : Text;
    #Ip : Text;
  };

  type User = {
    data : UserData;
    accessKeys : List.List<AccessKey>;
  };

  type UserDatabase = TrieMap.TrieMap<Nat, User>;

  stable var users : List.List<UserData> = List.nil<UserData>();
  stable var num_users : Nat = 0;

  stable var user_entries : [(Nat, User)] = [];

  var user_db : UserDatabase = TrieMap.fromEntries<Nat, User>(user_entries.vals(), Nat.equal, Hash.hash);

  public query func register_user_data(arg : UserData) : async User {
    let _ = List.push<UserData>(arg, users);
    num_users := num_users + 1;
    let user = {
      data = arg;
      accessKeys = List.nil<AccessKey>();
    };
    return user;
  };

  public shared func create_access_key(arg : AccessKey) : async AccessKey {
    let private_key = Nat32.toText(Blob.hash(await Random.blob()));
    return arg;
  };

  //create controlled route
  public query func dump_all_users() : async List.List<UserData> {
    return users;
  };

  public shared func get_user_data(key : Text, id : Nat) : async ?UserData {

    switch (user_db.get(id)) {
      case (?user) {
        return ?user.data;
      };
      case (null) {
        return null;
      };
    };
  };

  public query func remove_user(key : Text, id : Nat) : async () {
    let _ = user_db.remove(id);
    return;
  };

  //upgrade hooks
  system func preupgrade() {
    user_entries := Iter.toArray<(Nat, User)>(user_db.entries());
  };

  system func postupgrade() {
    user_entries := [];
  };

};
