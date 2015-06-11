#include "person.h"
#include <iostream>

void print_age(Person*);

int main()
{
  Person *p = new Person("Analizo", 3);
  print_age(p);
  delete p;

  return 0;
}

void print_age(Person *p)
{
  std::cout<<p->getAge()<<std::endl;
}	

