package de.headjump.superstate.test {
import de.headjump.tests.OkTest;

public class TestSuperstate extends OkTest {
  public function TestSuperstate(test_method:String = null) {
    super(test_method);
  }
  public function testBla():void {
    ok(false);
  }
}
}