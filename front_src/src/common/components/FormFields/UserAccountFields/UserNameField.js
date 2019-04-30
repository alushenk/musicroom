// @flow
import React from 'react';
import {Input, Form} from "antd";

import {AUTH_FORM_FIELDS} from "../../../constants";

const FormItem = Form.Item;
const authFormFields = AUTH_FORM_FIELDS;

type Props = {
  form: {},
  fieldName?: string,
  placeholder?: string,
};

export const UserNameField = (props: Props) => {
  const {
    form: {
      getFieldDecorator,
    },
    fieldName = authFormFields.userName,
    placeholder = "Put user name...",
  } = props;

  return (
    <FormItem label="User Name">
      {getFieldDecorator(fieldName, {
        rules: [
          // TODO: check other validation rules here
          { required: true, message: 'Field is required.' }
        ]
      })(<Input placeholder={placeholder}/>)}
    </FormItem>
  );
};

export default UserNameField;
