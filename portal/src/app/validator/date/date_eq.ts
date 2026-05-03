import { AbstractControl, FormGroup, ValidationErrors, ValidatorFn } from '@angular/forms';

export const eqDate = (  
  source: string,
  target: string,
): ValidatorFn => {
  return (control: AbstractControl): ValidationErrors | null => {
    const formGroup = control as FormGroup;
    const sourceControl = formGroup.get(source);
    const targetControl = formGroup.get(target);

    // If controls don't exist yet, return null
    if (!sourceControl || !targetControl) return null;

    // Check if values match
    let sd = sourceControl.value;
    let td = targetControl.value;

    if (td !== sd) {
      return { date_eq: true };
    }
    return null;
  };
};
