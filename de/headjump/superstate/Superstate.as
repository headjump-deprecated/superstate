package de.headjump.superstate {

public class Superstate {
  private var _states:Object;
  private var _hooks:Object;
  private var _machine:SuperstateMachine;
  private var _name:String;
  private var _machine_path_info:Object;

  /**
   *
   * @param hooks.enter
   * @param hooks.leave
   * @param children
   */
  public function Superstate(hooks:Object = null, children:Object = null) {
    _states = children;
    _hooks = hooks;
    _machine = null;
    _name = ""; // set by machine
    _machine_path_info = null;
  }

  protected function get hooks():Object { return _hooks; }
  public function get machine():SuperstateMachine { return _machine; }
  internal function setMachine(val:SuperstateMachine):void { _machine = val; }

  internal function set machine_path_info(val:Object):void { _machine_path_info = val; }
  internal function get machine_path_info():Object { return _machine_path_info; }

  public function set name(val:String):void { _name = val; }
  public function get name():String { return _name; }

  public function get states():Object { return _states; }

  public function onEnter():void {
    if(_hooks && _hooks.enter) _hooks.enter();
  }

  public function onLeave(path:Array):void {
    if(_hooks && _hooks.leave) _hooks.leave(path);
  }
}
}