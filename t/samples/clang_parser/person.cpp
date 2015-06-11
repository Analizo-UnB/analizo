#include "person.h"

Person::Person(std::string _name, int _age):name(_name), age(_age)
{

}

int
Person::getAge() const
{
  return age;
}

std::string
Person::getName() const
{
  return name;
}

void
Person::makeBirthday()
{
  age +=1;
}

