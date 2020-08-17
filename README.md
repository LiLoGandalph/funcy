Utility classes and functions for comfortable and "safe" functional programming.

## Usage

A simple usage example:

```dart
import 'package:funcy/funcy.dart';
import 'package:meta/meta.dart';

void main() {
  final employeeJson = retrieveEmployeeJson();
  final maybeEmployee =
      Employee.tryFromJson(employeeJson) | tryFallbackEmployee();
  maybeEmployee.option(
    () => print('Something really bad is happening '
        'even fallback employee does not work.'),
    (employee) => print('${employee.name} is ${employee.age}.'),
  );
}

Map<String, dynamic> retrieveEmployeeJson() => <String, dynamic>{
      'name': 'Bob',
      'position': 'boss',
      'age': 42,
    };

Option<Employee> tryFallbackEmployee() => Some(
      Employee(
        name: 'Fallback Employee',
        position: Position.subsubboss,
        age: -1,
      ),
    );

enum Position {
  boss,
  subboss,
  subsubboss,
}

Option<Position> tryParsePosition(String positionStr) {
  switch (positionStr) {
    case 'boss':
      return const Some(Position.boss);
    case 'subboss':
      return const Some(Position.subboss);
    case 'subsubboss':
      return const Some(Position.subsubboss);
    default:
      return const None();
  }
}

class Employee {
  Employee({
    @required this.name,
    @required this.position,
    @required this.age,
  });

  final String name;
  final Position position;
  final int age;

  static Option<Employee> tryFromJson(Map<String, dynamic> json) {
    return json.tryGet<String>('name').bind(
      (name) {
        return json.tryGet<String>('position').bind(tryParsePosition).bind(
          (position) {
            return json.tryGet<int>('age').guard(_ageTest).map(
              (age) {
                return Employee(
                  name: name,
                  position: position,
                  age: age,
                );
              },
            );
          },
        );
      },
    );
  }

  static bool _ageTest(int age) => age >= 18;
}
```