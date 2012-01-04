package de.headjump.superstate {

public class Superstate {
  private var _parent:Superstate;
  private var _states:Object;
  private var _hooks:Object;
  private var _machine:SuperstateMachine;

  public function Superstate(hooks:Object = null, states:Object = null) {
    _states = states;
    _hooks = hooks;
    _parent = null;
    _machine = null;
  }

  protected function get hooks():Object { return _hooks; }
  protected function get machine():SuperstateMachine { return _machine; }

  public function set parent(val:Superstate):void { _parent = val; }

  public function get path_to_root():Array {
    var res:Array = [];
    var par:Object = this;
    while((par = par.parent) && (!par is SuperstateMachine)) {
      res.push(par);
    }
    return res;
  }

  public function onEnter():void {
    if(_hooks && _hooks.enter) _hooks.enter();
  }

  public function onLeave():void {
    if(_hooks && _hooks.leave) _hooks.enter();
  }
}
}