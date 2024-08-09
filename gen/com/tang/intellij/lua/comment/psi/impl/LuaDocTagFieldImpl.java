// This is a generated file. Not intended for manual editing.
package com.tang.intellij.lua.comment.psi.impl;

import java.util.List;
import org.jetbrains.annotations.*;
import com.intellij.lang.ASTNode;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiElementVisitor;
import com.intellij.psi.util.PsiTreeUtil;
import static com.tang.intellij.lua.comment.psi.LuaDocTypes.*;
import com.intellij.extapi.psi.ASTWrapperPsiElement;
import com.tang.intellij.lua.comment.psi.*;

public class LuaDocTagFieldImpl extends ASTWrapperPsiElement implements LuaDocTagField {

  public LuaDocTagFieldImpl(@NotNull ASTNode node) {
    super(node);
  }

  public void accept(@NotNull LuaDocVisitor visitor) {
    visitor.visitTagField(this);
  }

  @Override
  public void accept(@NotNull PsiElementVisitor visitor) {
    if (visitor instanceof LuaDocVisitor) accept((LuaDocVisitor)visitor);
    else super.accept(visitor);
  }

  @Override
  @Nullable
  public LuaDocAccessModifier getAccessModifier() {
    return findChildByClass(LuaDocAccessModifier.class);
  }

  @Override
  @Nullable
  public LuaDocClassNameRef getClassNameRef() {
    return findChildByClass(LuaDocClassNameRef.class);
  }

  @Override
  @Nullable
  public LuaDocCommentString getCommentString() {
    return findChildByClass(LuaDocCommentString.class);
  }

  @Override
  @Nullable
  public LuaDocTy getTy() {
    return findChildByClass(LuaDocTy.class);
  }

  @Override
  @Nullable
  public PsiElement getId() {
    return findChildByType(ID);
  }

}