#ifndef PERSON_H
#define PERSON_H

#include <string>

class Person{

  public:
	Person(std::string, int);
	int getAge() const;
	std::string getName() const;

  private:
	std::string name;
	int age;
	void makeBirthday();	
};

#endif

