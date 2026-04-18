import { Component, signal } from '@angular/core';
//import { Autocomplete } from '../../components/autocomplete/autocomplete';
//import { IAutocompleteItem } from '../../models/autocomplete';
import { CommonModule, NgClass } from '@angular/common';
import { Carousel } from '../../components/carousel/carousel';

@Component({
  selector: 'app-landing',
  imports: [CommonModule, Carousel],
  templateUrl: './landing.html',
  styleUrl: './landing.css',
})
export class Landing {
handleCarouselScroll($event: number) {
console.log('Carousel scrolled to index:', $event);
}
  /* students:IAutocompleteItem[] = [
    { id: 1, value: '1', label: 'John Doe', image: '', status: 'active', description: 'Web Development Student' },
    { id: 2, value: '2', label: 'Jane Smith', image: '', status: 'active', description: 'UI/UX Design Student' },
    { id: 3, value: '3', label: 'Bob Johnson', image: '', status: 'inactive', description: 'Digital Marketing Student' },
  ];

  // Search Function
  searchStudents = async (searchTerm: string): Promise<any[]> => {
    return new Promise(resolve => {
      setTimeout(() => {
        resolve(this.students.filter(student => 
          student.label.toLowerCase().includes(searchTerm.toLowerCase())
        ).slice(0, 5)); // Limit to 5 results
      }, 300);
    });
  };

  // Autocomplete Config
  autocompleteConfig = {
    minLength: 5,
    maxItems: 5,
    debounce: 300,
    showImage: false,
    showStatus: true,
    placeholder: 'Search students...',
    noResultsMessage: 'No students found.',
    loadingMessage: 'Loading students...'
  };

  // Handle Selected Student
  onStudentSelected(student: any) {
    //console.log('Selected Student:', student);
    // Update studentId, etc.
  } */

    // --- Sign-Up Email Capture ---
  email = signal<string>('');
  isLoading = signal<boolean>(false);
  
  // --- Featured Courses Data ---
  popularCourses = signal<any[]>([
    { 
      id: 1, 
      title: 'Complete React Course', 
      instructor: 'John Doe', 
      rating: 4.9, 
      students: '12,450', 
      price: '$49.99', 
      image: 'https://via.placeholder.com/300/6366f1/ffffff?text=React' 
    },
    { 
      id: 2, 
      title: 'UI/UX Masterclass', 
      instructor: 'Jane Smith', 
      rating: 4.8, 
      students: '8,900', 
      price: '$39.99', 
      image: 'https://via.placeholder.com/300/a855f7/ffffff?text=Design' 
    },
    { 
      id: 3, 
      title: 'Advanced Node.js', 
      instructor: 'Mike Johnson', 
      rating: 4.7, 
      students: '6,300', 
      price: '$59.99', 
      image: 'https://via.placeholder.com/300/ec4899/ffffff?text=NodeJS' 
    },
    { 
      id: 4, 
      title: 'Digital Marketing 2024', 
      instructor: 'Sarah Wilson', 
      rating: 4.9, 
      students: '15,200', 
      price: '$44.99', 
      image: 'https://via.placeholder.com/300/10b981/ffffff?text=Marketing' 
    }
  ]);
  
  // --- Short Courses Data ---
  shortCourses = signal<any[]>([
    { 
      id: 5, 
      title: 'CSS Grid in 20 Minutes', 
      description: 'Master CSS Grid layout in under 20 minutes', 
      time: '20 min', 
      level: 'Beginner', 
      image: 'https://via.placeholder.com/400/8b5cf6/ffffff?text=CSS+Grid' 
    },
    { 
      id: 6, 
      title: 'Tailwind CSS Crash Course', 
      description: 'Quick crash course to become a Tailwind wizard', 
      time: '35 min', 
      level: 'Beginner', 
      image: 'https://via.placeholder.com/400/14b8a6/ffffff?text=Tailwind' 
    },
    { 
      id: 7, 
      title: 'JavaScript ES6 Quick Tips', 
      description: 'Essential ES6 features every developer needs', 
      time: '45 min', 
      level: 'Intermediate', 
      image: 'https://via.placeholder.com/400/f59e0b/ffffff?text=ES6' 
    }
  ]);
  
  // --- Testimonials ---
  testimonials = signal<any[]>([
    { 
      id: 1, 
      name: 'Emily Chen', 
      role: 'Frontend Developer', 
      content: 'The React courses transformed my career. KMS is the best LMS platform out there!' 
    },
    { 
      id: 2, 
      name: 'David Wilson', 
      role: 'UI Designer', 
      content: 'Short courses are perfect for busy schedules. I learned CSS Grid in 20 minutes!' 
    },
    { 
      id: 3, 
      name: 'Rachel Green', 
      role: 'Marketing Manager', 
      content: 'The digital marketing course gave me all the skills I needed for my company.' 
    }
  ]);
  
  // --- Email Capture ---
  onSubscribe() {
    if (!this.email()) return;
    this.isLoading.set(true);
    
    setTimeout(() => {
      this.isLoading.set(false);
      alert('Thank you for subscribing!');
      this.email.set('');
    }, 1500);
  }
  
  scrollToSection(id: string) {
    const element = document.getElementById(id);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  }
}
