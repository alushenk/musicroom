// @flow
import React from 'react';
import {Input, Form} from "antd";

import {AUTH_FORM_FIELDS} from "../../../constants";

const FormItem = Form.Item;
const authFormFields = AUTH_FORM_FIELDS;

type Props = {
  form: {},
  fieldName?: string,
  validateToMatchFieldName?: string,
};

export const UserRepeatPasswordField = (props: Props) => {
  const {
    form: {
      getFieldDecorator,
    },
    fieldName = authFormFields.repeatPassword,
  } = props;

  const validateRepeatPassword = (rule, value, cb) => {
    const {
      form: { getFieldValue },
      validateToMatchFieldName = authFormFields.password
    } = props;

    if (value !== getFieldValue(validateToMatchFieldName)) {
      return cb(true);
    }

    return cb();
  };

  return (
    <FormItem label="Repeat Password">
      {getFieldDecorator(fieldName, {
        rules: [
          { required: true, message: 'Password is required.' },
          { validator: validateRepeatPassword, message: `Password didn't match.` }
        ]
      })(<Input.Password placeholder="Repeat password..."/>)}
    </FormItem>
  );
};

export default UserRepeatPasswordField;
