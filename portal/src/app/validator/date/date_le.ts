import { AbstractControl, FormGroup, ValidationErrors, ValidatorFn } from '@angular/forms';

export const leDate = (  
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
    let sd = new Date(sourceControl.value);
    let td = new Date(targetControl.value);
    console.log(td, sd);
    if (+td > +sd) {
      return { date_le: true };
    }
    return null;
  };
};
