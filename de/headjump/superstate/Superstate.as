package de.headjump.superstate {

public class Superstate {
  private var _parent:Superstate;

  public function Superstate(children:Object = null) {
    parent = null;
  }

  public function set parent(val:Superstate):void {
    _parent = val;
  }
}
}